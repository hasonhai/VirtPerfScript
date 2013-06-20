#!/bin/bash
# A script to run test automatically, need modify when using
# Usage:
#       ./RunTestRemote.sh <number of test> <tshark|tcpdump> [threads]
#       ./RunTestRemote.sh <number of test> <tshark|tcpdump> [size <size of test>]
#       [threads]: when there is threads, use -P option of Iperf
#                  Otherwise, run multiple instances of Iperf
#       <tshark|tcpdump>: Use Tshark or TCPdump to capture traffic, tcpdump by default
#       <number of test>: Defaut is 1
#                         Number of Threads/Processes
#                         Number of time capture traffic

RUN_IPERF_SERVER="sh ControlIperfServer.sh start"
STOP_IPERF_SERVER="sh ControlIperfServer.sh stop"
RUN_TCPDUMP="sh ControlTCPdump.sh start"
STOP_TCPDUMP="sh ControlTCPdump.sh stop"
RUN_TSHARK="sh ControlTshark.sh start"
STOP_TSHARK="sh ControlTshark.sh stop"
TARGET_ITF="10.10.10.253"
RUN_CLIENT="iperf -c $TARGET_ITF"
RECEIVER="10.10.11.253"
SENDER="134.59.129.103"
SENDER_PHY_NAME="xenbr0"
RECEIVER_PHY_NAME="em2"
DIRECTORY="CapturedTraffic$( date +%Y%m%d%H%M )"
STOREDPATH="/home/HaSonHai_Captures/Dump"
TCP_DURATION="60"
TEST_TYPE="time"
SIZE=10737418240 #10GBs

if [ "$1" = "" ]; then
    MAX_TEST=1;
else
    MAX_TEST=$1;
fi

if [ "$2" = tshark ]; then
    RUN_CAPTURE="$RUN_TSHARK"
    STOP_CAPTURE="$STOP_TSHARK"
else
    RUN_CAPTURE="$RUN_TCPDUMP"
    STOP_CAPTURE="$STOP_TCPDUMP"
fi

if [ "$3" = threads ]; then
    RUN_MODEL="threads"
else
    if [ "$3" = size ]; then
        TEST_TYPE="size"
        SIZE=$4
    fi
    RUN_MODEL="processes"
fi

# Run server daemon on RECEIVER
CMD=ssh
CMD_OPTIONS="root@$RECEIVER"
echo Send Iperf Start Command...
$CMD $CMD_OPTIONS "$RUN_IPERF_SERVER"
sleep 5 # Waiting for server to run

CMD=ssh
CMD_OPTIONS="root@$RECEIVER" 
DIROK=$( $CMD $CMD_OPTIONS "mkdir $STOREDPATH/$DIRECTORY && echo ok" )
if [ "$DIROK" = ok ]; then
    echo Directory is created at $STOREDPATH/$DIRECTORY on $RECEIVER
else
    echo Cannot create directory\! Please be careful\!
fi
CMD=ssh
CMD_OPTIONS="root@$SENDER"
DIROK_SENDER=$( $CMD $CMD_OPTIONS "mkdir $STOREDPATH/$DIRECTORY && echo ok" )
if [ "$DIROK_SENDER" = ok ]; then
    echo Directory is created at $STOREDPATH/$DIRECTORY on client $SENDER
else
    echo Cannot create directory on sender $SENDER\! Please be careful\!
fi

for INCR in $(seq $MAX_TEST)
do
    echo Running Test $INCR
    
    echo Setting-up program to capture traffic...
    INCR_PADDING=$( printf %02d $INCR )
    FILENAME="$STOREDPATH/$DIRECTORY/Traffic$INCR_PADDING.cap"
    CMD=ssh
    CMD_OPTIONS="root@$RECEIVER"
    $CMD $CMD_OPTIONS "$RUN_CAPTURE $FILENAME $RECEIVER_PHY_NAME"
    sleep 5
    
    # Running the iperf client
    if [ "$TEST_TYPE" = size ]; then
        TEST_SIZE=`expr $SIZE / $INCR`
    fi

    SLEEPTIME=1
    CMD=ssh
    CMD_OPTIONS="root@$SENDER"
#    $CMD $CMD_OPTIONS "$RUN_CAPTURE $FILENAME $SENDER_PHY_NAME"
    if [ "$RUN_MODEL" = threads ]; then
        echo "Running Iperf Client as threads model on $SENDER"
#        $CMD $CMD_OPTIONS "$RUN_CLIENT -t $TCP_DURATION -P $INCR"
        #Lacking of size test
        #For Dom0
        $CMD $CMD_OPTIONS "./iperf -c $TARGET_ITF -t $TCP_DURATION -P $INCR" 
    else
        echo "Running Iperf Client as processes model on $SENDER"
        if [ "$TEST_TYPE" = size ]; then
            $CMD $CMD_OPTIONS "sh parallel.sh -j $INCR \"$RUN_CLIENT -n $TEST_SIZE\""
        else
            # For CentOS, or we can use the same command with Ubuntu
            $CMD $CMD_OPTIONS "sh parallel.sh -j $INCR \"$RUN_CLIENT -t $TCP_DURATION\""
            SLEEPTIME=1
            # For Ubuntu, need to install "moreutils" packet
            # ARGS="$( printf '%d ' `seq $INCR` )"
            # $CMD $CMD_OPTIONS "parallel sh -c \"$RUN_CLIENT -t $TCP_DURATION &\" -- $ARGS"
            #SLEEPTIME=$(( $TCP_DURATION + 5 ))
        fi
    fi
    sleep $SLEEPTIME
#    $CMD $CMD_OPTIONS "$STOP_CAPTURE"
    
    #Stop capturing packet
    CMD=ssh 
    CMD_OPTIONS="root@$RECEIVER"
    echo Send Capture Stop Command...
    $CMD $CMD_OPTIONS "$STOP_CAPTURE"  
    sleep 5 #Wait for writing file to harddrive

done

#Stop Iperf Deamon
CMD=ssh
CMD_OPTIONS="root@$RECEIVER"
echo Send IPERF Server STOP Command...
$CMD $CMD_OPTIONS "$STOP_IPERF_SERVER"
sleep 2
echo Teng Teng Teng\! Test done\! Congrats\! 


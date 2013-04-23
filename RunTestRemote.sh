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
RUN_CLIENT="iperf -c"
TARGET_ITF="10.10.10.253" #Target network interface
REMOTE_SERVER="10.10.11.253"
REMOTE_CLIENT="10.10.11.101"
CLIENT_PHY_NAME="eth3"
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

# Run server daemon on remote server
CMD=ssh
CMD_OPTIONS="root@$REMOTE_SERVER"
echo Send Iperf Start Command...
$CMD $CMD_OPTIONS "$RUN_IPERF_SERVER"
sleep 5 # Waiting for server to run

CMD=ssh
CMD_OPTIONS="root@$REMOTE_SERVER" 
DIROK=$( $CMD $CMD_OPTIONS "mkdir $STOREDPATH/$DIRECTORY && echo ok" )
if [ "$DIROK" = ok ]; then
    echo Directory is created at $STOREDPATH/$DIRECTORY on $REMOTE_SERVER
else
    echo Cannot create directory\! Please be careful\!
fi
CMD=ssh
CMD_OPTIONS="root@$REMOTE_CLIENT"
DIROK_CLIENT=$( $CMD $CMD_OPTIONS "mkdir $STOREDPATH/$DIRECTORY && echo ok" )
if [ "$DIROK_CLIENT" = ok ]; then
    echo Directory is created at $STOREDPATH/$DIRECTORY on client $REMOTE_CLIENT
else
    echo Cannot create directory on client side\! Please be careful\!
fi

for INCR in $(seq 1 $MAX_TEST)
do
    echo Running Test $INCR
    
    echo Setting-up program to capture traffic...
    INCR_PADDING=$( printf %02d $INCR )
    FILENAME="$STOREDPATH/$DIRECTORY/Traffic$INCR_PADDING.cap"
    CMD=ssh
    CMD_OPTIONS="root@$REMOTE_SERVER"
    $CMD $CMD_OPTIONS "$RUN_CAPTURE $FILENAME em2"
    sleep 5
    
    # Running the client
    if [ "$TEST_TYPE" = size ]; then
        TEST_SIZE=`expr $SIZE / $INCR`
    fi

    CMD=ssh
    CMD_OPTIONS="root@$REMOTE_CLIENT"
    $CMD $CMD_OPTIONS "$RUN_CAPTURE $FILENAME $CLIENT_PHY_NAME"
    if [ "$RUN_MODEL" = threads ]; then #Iperf command parsing wrongly, not know whether fixed or not
#        echo "Running Iperf Client as threads model on $REMOTE_CLIENT"
#        $CMD $CMD_OPTIONS "$RUN_CLIENT $TARGET_ITF -t $TCP_DURATION -P $INCR"
        echo Threads model is not good, please use procs model\!
    else
        echo "Running Iperf Client as processes model on $REMOTE_CLIENT"
        if [ "$TEST_TYPE" = size ]; then
            $CMD $CMD_OPTIONS "sh parallel.sh -j $INCR \"$RUN_CLIENT $TARGET_ITF -n $TEST_SIZE\""
        else
            $CMD $CMD_OPTIONS "sh parallel.sh -j $INCR \"$RUN_CLIENT $TARGET_ITF -t $TCP_DURATION\""
        fi
    fi
    sleep 1
    $CMD $CMD_OPTIONS "$STOP_CAPTURE"
    
    #Stop capturing packet
    CMD=ssh 
    CMD_OPTIONS="root@$REMOTE_SERVER"
    echo Send Capture Stop Command...
    $CMD $CMD_OPTIONS "$STOP_CAPTURE"  
    sleep 5 #Wait for writing file to harddrive

done

#Stop Iperf Deamon
CMD=ssh
CMD_OPTIONS="root@$REMOTE_SERVER"
echo Send IPERF Server STOP Command...
$CMD $CMD_OPTIONS "$STOP_IPERF_SERVER"
sleep 2
echo Teng Teng Teng\! Test done\! Congrats\! 


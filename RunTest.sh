#!/bin/bash
# A script to run test automatically, need modify when using
# Usage:
#       ./SelfRunTests.sh <number of test> [threads [tshark]]
#       ./SelfRunTests.sh <number of test> [tshark]
#       [threads]: when there is threads, use -P option of Iperf
#                  Otherwise, run multiple instances of Iperf
#       [tshark]: Use Tshark to capture traffic, tcpdump by default
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
TARGET_SERVER="10.10.10.253"
REMOTE_SERVER="134.59.129.197"
DIRECTORY="CapturedTraffic$( date +%Y%m%d%H%M )"
STOREDPATH="/home/HaSonHai_Captures/Dump"
TCP_DURATION="60"

if [ "$1" = "" ]; then
    MAX_TEST=1;
else
    MAX_TEST=$1;
fi

if [ "$2" = threads ]; then
    if [ "$3" = tshark ]; then
        RUN_CAPTURE="$RUN_TSHARK"
        STOP_CAPTURE="$STOP_TSHARK"
    else
        RUN_CAPTURE="$RUN_TCPDUMP"
        STOP_CAPTURE="$RUN_TCPDUM"
    fi
else
    if [ "$2" = tshark ]; then
        RUN_CAPTURE="$RUN_TSHARK"
        STOP_CAPTURE="$STOP_TSHARK"
    else
        RUN_CAPTURE="$RUN_TCPDUMP"
        STOP_CAPTURE="$STOP_TCPDUMP"
    fi
fi

# Run server daemon on remote server
CMD=ssh
CMD_OPTIONS="root@$REMOTE_SERVER"
echo Send Iperf Start Command...
$CMD $CMD_OPTIONS "$RUN_IPERF_SERVER"
sleep 5 # Waiting for server to run

CMD=ssh
CMD_OPTIONS="root@$REMOTE_SERVER" 
DIROK=$($CMD $CMD_OPTIONS "mkdir $STOREDPATH/$DIRECTORY && echo ok")
if [ "$DIROK" = ok ]; then
    echo Directory is created at $STOREDPATH/$DIRECTORY
else
    echo Cannot create directory\! Please be careful\!
fi

DIROK_CLIENT=$( mkdir $STOREDPATH/$DIRECTORY && echo ok )
if [ "$DIROK_CLIENT" = ok ]; then
    echo Directory on client side is created at $STOREDPATH/$DIRECTORY
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
    $CMD $CMD_OPTIONS "$RUN_CAPTURE $FILENAME"
    sleep 5
    
    # Running the client
    $RUN_CAPTURE $FILENAME client
    if [ "$2" = threads ]; then
        echo "Running Iperf Client as threads model"
        $RUN_CLIENT $TARGET_SERVER -t $TCP_DURATION -P $INCR
    else
        echo "Running Iperf Client as processes model"
        sh parallel.sh -j $INCR "$RUN_CLIENT $TARGET_SERVER -t $TCP_DURATION"
    fi
    sleep 1
    $STOP_CAPTURE
    
    #Stop capturing packet
    CMD=ssh 
    CMD_OPTIONS="root@$REMOTE_SERVER"
    echo Send Capture Stop Command...
    $CMD $CMD_OPTIONS "$STOP_CAPTURE"  
    sleep 5 #Wait for writing file to harddrive

done

#Stop Iperf Deamon
CMD=ssh
CMD_OPTIONS="$REMOTE_SERVER"
echo Send IPERF Server STOP Command...
$CMD $CMD_OPTIONS "$STOP_IPERF_SERVER"
sleep 2
echo Teng Teng Teng\! Test done\! Congrats\! 


#!/bin/bash
# A script to run test automatically, need modify when using
# Usage:
#       ./SelfRunTests.sh <number of test> [threads]
#       [threads]: when there is threads, use -P option of Iperf
#                  Otherwise, run multiple instances of Iperf
#       <number of test>: Defaut is 1
#                         Number of Threads/Processes
#                         Number of time capture traffic

RUN_IPERF_SERVER="sh ControlIperfServer.sh start"
STOP_IPERF_SERVER="sh ControlIperfServer.sh stop"
RUN_TCPDUMP="sh ControlTCPdump.sh start"
STOP_TCPDUMP="sh ControlTCPdump.sh stop"
RUN_CLIENT="iperf -c"
TARGET_SERVER="10.10.10.253"
REMOTE_SERVER="134.59.129.197"
DIRECTORY="CapturedTraffic$( date +%Y%m%d%H%M )"
TCP_DURATION="60"

if [ "$1" = "" ]; then
    MAX_TEST=1;
else
    MAX_TEST=$1;
fi

# Run server daemon on remote server
CMD=ssh
CMD_OPTIONS="root@$REMOTE_SERVER"
echo Send Iperf Start Command...
$CMD $CMD_OPTIONS "$RUN_IPERF_SERVER"
sleep 10 # Waiting for server to run

CMD=ssh
CMD_OPTIONS="root@$REMOTE_SERVER" 
DIROK=$($CMD $CMD_OPTIONS "mkdir $DIRECTORY && echo ok")
if [ "$DIROK" = ok ]; then
    echo Directory is created\!
else
    echo Cannot create directory\! Please be careful\!
fi

for INCR in $(seq 1 $MAX_TEST)
do
    echo Running Test $INCR
    
    #Prepair TCP to capture traffic
    echo Setting-up TCPdump for capturring traffic
    INCR_PADDING=$( printf %02d $INCR )
    FILENAME="$DIRECTORY/Traffic$INCR_PADDING.dmp"
    CMD=ssh
    CMD_OPTIONS="root@$REMOTE_SERVER"
    $CMD $CMD_OPTIONS "$RUN_TCPDUMP $FILENAME"
    sleep 10
    
    # Running the client
    if [ "$2" = threads ]; then
        echo "Running Iperf Client as threads model"
        $RUN_CLIENT $TARGET_SERVER -t $TCP_DURATION -P $INCR
    else
        echo "Running Iperf Client as processes model"
        sh parallel.sh -j $INCR "$RUN_CLIENT $TARGET_SERVER -t $TCP_DURATION"
    fi
    sleep 5
    #Stop TCPdump
    CMD=ssh 
    CMD_OPTIONS="root@$REMOTE_SERVER"
    echo Send TCPDump Stop Command...
    $CMD $CMD_OPTIONS "$STOP_TCPDUMP"  
    sleep 15 #Wait for TCPdump write file to harddrive

done

#Stop Iperf Deamon
CMD=ssh
CMD_OPTIONS="$REMOTE_SERVER"
echo Send IPERF Server STOP Command...
$CMD $CMD_OPTIONS "$STOP_IPERF_SERVER"
sleep 10
echo Teng Teng Teng\! Test done\! Congrats\! 


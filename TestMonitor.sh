#!/bin/bash
# To monitor and run test.
# Use only for case of One-to-One test.
# For case of One-to-Many and Many-to-One, should use Perl and Interactive SSH session
# Usage:
# ./TestMonitor.sh <number of test> [parallel <number of procs>]

#OPTIONS
DIRECTORY="CapturedTraffic$( date +%M%H%d%m%Y )"
TCP_DURATION="60"
NUMBER_OF_THREADS_ON_CLIENT="1"
USER="root"
TCP_VERSION="cubic"

SERVER="134.59.129.197" #default receiving server
CLIENT="134.59.129.105" #default sending server

#Note: Test interface of Server is em2 while client is em1. Should check before use

#default number of test
if [ "$1" = "" ]; then
    MAX_TEST=1;
else
    MAX_TEST=$1;
fi

#COMMANDS
RUN_IPERF_SERVER="sh ControlIperfServer.sh start"
STOP_IPERF_SERVER="sh ControlIperfServer.sh stop"
RUN_TCPDUMP="sh ControlTCPdump.sh start"
STOP_TCPDUMP="sh ControlTCPdump.sh stop"
RUN_TSHARK="sh ControlTshark.sh start"
STOP_TSHARK="sh ControlTshark stop"
RUN_IPERF_CLIENT="iperf -c $SERVER -t $TCP_DURATION -P $NUMBER_OF_THREADS_ON_CLIENT"
CHANGE_TCP_VERSION="sysctl -w net.ipv4.tcp_congestion_control=$TCP_VERSION"
CREATE_DIRECTORY="mkdir $DIRECTORY && echo ok"
CHECK_IPERF_CONTROL="test -f ControlIperfServer.sh && echo Found || echo NotFound"
CHECK_TCPDUMP_CONTROL="test -f ControlTCPdump.sh && echo Found || echo NotFound"
CHECK_PARALLEL_SCRIPT="test -f parallel.sh && echo Found || echo NotFound"
SSH="ssh -v"
SCP=scp

function SSHcommand() {
    local REMOTE_HOST=$1
    local COMMAND=$2
    $SSH $USER@$REMOTE_HOST "$COMMAND"
}

function SCPcommand() {
    local REMOTE_HOST=$1
    local FILE=$2
    $SCP $( pwd )/$FILE $USER@$REMOTE_HOST:
}

TEMP_CLIENT_GROUP=""
function generateTempIPlist() {
    TEMP_CLIENT_GROUP=""
    local CLIENT_START_IP=$1
    local CLIENT_TEMP_END_IP=$2
    for TEMP in $( seq $CLIENT_START_IP $CLIENT_END_IP )
    do
        TEMP_CLIENT_GROUP="$TEMP_CLIENT_GROUP $CLIENT_SUBNET.TEMP"
    done
}

#Generate IP Full List
generateTempIPlist $CLIENT_START_IP $CLIENT_END_IP
CLIENTS=$TEMP_CLIENT_GROUP

#Check server setting
IPERFOK=$( SSHcommand $SERVER $CHECK_IPERF_CONTROL )
if [ "$IPERFOK" = Found ]; then
    echo Iperf Controlling Script is OK\! Proceed...
else
    echo There is no Iperf Controlling Script on $SERVER
    echo Copying Iperf Controlling Script to $SERVER
    SCPcommand $SERVER ControlIperfServer.sh
    EXECUTABLE="chmod 755 ControlIperfServer.sh && echo ok"
    SSHcommand $SERVER $EXECUTABLE
fi

TCPDUMPOK=$( SSHcommand $SERVER $CHECK_IPERF_CONTROL )
if [ "$TCPDUMPOK" = Found ]; then
    echo TCPdump Controlling Script is OK\! Proceed...
else
    echo There is no TCPdump Controlling Script on $SERVER
    echo Copying TCPdump Controlling Script to $SERVER
    SCPcommand $SERVER ControlTCPdump.sh
    EXECUTABLE="chmod 755 ControlTCPdump.sh && echo ok"
    SSHcommand $SERVER $EXECUTABLE
fi

#Create Directory to store traffic captured file
echo Create directory to store files...
DIROK=$( SSHcommand $SERVER $CREATE_DIRECTORY )
if [ "$DIROK" = ok ]; then
    echo Directory is created\!
else
    echo Cannot create directory\! Please be careful\!
fi

# Check client setting

if [ "$2" = parallel ]; then
    for CLIENT in $CLIENTS
    do
        PARALLELOK=$( SSHcommand $CLIENT $CHECK_PARALLEL_SCRIPT )
        if [ "$PARALLELOK" = Found ]; then
            echo Parallel script is OK\! Proceed...
        else
            echo There is no Parallel Script on $CLIENT
            echo Copying TCPdump Controlling Script to $CLIENT
            SCPcommand $CLIENT parallel.sh
            EXECUTABLE="chmod 755 parallel.sh && echo ok"
            SSHcommand $CLIENT $EXECUTABLE
        fi
    done
fi

#Run Iperf server to receive traffic
echo Turn on Iperf server at $SERVER ...
SSHcommand $SERVER $RUN_IPERF_SERVER
sleep 10

for INCR in $(seq 1 $MAX_TEST)
do
    echo Running Test $INCR
    
    #Prepair TCP to capture traffic
    echo Setting-up TCPdump for capturring traffic
    INCR_PADDING=$( printf %02d $INCR )
    FILENAME="$DIRECTORY/Traffic$INCR_PADDING.dmp"
    CMD_TO_SEND="$RUN_TCPDUMP $FILENAME"
    SSHcommand $SERVER $CMD_TO_SEND 
    sleep 5

    #Running the client
    let "CLIENT_TEMP_END_IP = $CLIENT_START_IP + $INCR - 1"
    generateIPlist $CLIENT_START_IP $CLIENT_TEMP_END_IP
    if [ "$2" = parallel ]; then
        NUMBER_OF_PROCS_ON_CLIENT=$3
        #bla bla bla
        #implement later
    else
        sh parallel.sh -j $INCR \"$SSH $USER@* \'$RUN_IPERF_CLIENT\'\" $TEMP_CLIENT_GROUP
    fi
    #Stop TCPdump
    echo Send TCPDump Stop Command...
    SSHcommand $SERVER $STOP_TCPDUMP  
    sleep 10 #Wait for TCPdump write file to harddrive
done

#Stop Iperf Deamon
echo Send IPERF Server STOP Command...
SSHcommand $SERVER $STOP_IPERF_SERVER
sleep 5
echo Teng Teng Teng\! Test done\! Congrats\!

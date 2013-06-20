#!/bin/bash
# This file use to control tcpdump of many machines having continuous ip addresses
# Syntax: ./pssh.sh <start|stop> <NoVMs>

RUN_CAPTURE="sh ControlTCPdump.sh start"
STOP_CAPTURE="sh ControlTCPdump.sh stop"

EXEC=$1
BASE_ADDR=101
MAX_ADDR=$(( $BASE_ADDR + $2 - 1 ))
SENDER_INTF="eth9"
RECEIVER_INTF="em2"
SENDER_PATH="Captures/Sender_"
RECEIVER_PATH="/home/HaSonHai_Captures/Dump/"
FOLDER_NAME="VMWARE60sMultiVMsCubic06/"
FILENAME="Traffic$( printf %02d $2 ).cap"

if [ "$EXEC" = start ]; then
    ssh root@10.10.11.253 "$RUN_CAPTURE $RECEIVER_PATH$FOLDER_NAME$FILENAME $RECEIVER_INTF"
    for ADDR in `seq $BASE_ADDR $MAX_ADDR`
    do
        ssh root@10.10.11.$ADDR "$RUN_CAPTURE $SENDER_PATH$FOLDER_NAME$FILENAME $SENDER_INTF" &
    done
    wait
fi

if [ "$EXEC" = stop ]; then
   ssh root@10.10.11.253 "$STOP_CAPTURE"
   for ADDR in `seq $BASE_ADDR $MAX_ADDR`
   do
        ssh root@10.10.11.$ADDR "$STOP_CAPTURE" &
   done
   wait
fi

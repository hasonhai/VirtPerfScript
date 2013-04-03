#!/bin/bash
# Script to Start/Stop TCP
# Usage: ./ControlTCPdump.sh start|stop [filename] [interface]
# Created by: Ha Son Hai (hasonhai124(at)gmail.com)

CONSOLE_OUTPUT="tcpdump$( date +%m%d ).console"
HOST_NAME=`hostname`

#Default filename:
if [ "$2" = "" ]; then
    FILENAME="traffic.dmp"
    ITF="em2"
else
    FILENAME=$2
    if [ "$3" = "" ]; then
        ITF="em2"
    else
        ITF=$3
    fi
fi

if [ "$1" = start ]; then
    echo $(date) $FILENAME >> $CONSOLE_OUTPUT
    if [ "" = "$(pidof tcpdump)" ]; then
        nohup tcpdump -s 96 -w $FILENAME -i $ITF -n tcp > /dev/null &>> $CONSOLE_OUTPUT &
        echo [$HOST_NAME] TCPdump is started\!
    else
        echo [$HOST_NAME] There is runnung process. Kill All\!
        killall -q tcpdump #Quiet, don't talk
        sleep 1
        if [ "" = "$(pidof tcpdump)" ]; then
            echo [$HOST_NAME] Restarting TCPdump...
            nohup tcpdump -s 96 -w $FILENAME -i $ITF -n tcp >/dev/null &>> $CONSOLE_OUTPUT &
            echo [$HOST_NAME] TCPdump is started\!
        else
            echo [$HOST_NAME] Error\! Cannot kill them\!
            exit 0
        fi
    fi
else 
    if [ "$1" = stop ]; then
        TD=`pidof tcpdump`
        if [ -n "$TD" ]; then
            kill "$TD"
        fi
        sleep 1
        if [ "" = "$(pidof tcpdump)" ]; then
            echo [$HOST_NAME] TCPdump is stopped\!
        else
            echo [$HOST_NAME] Error\! Cannot kill them\!
            exit 0
        fi        
    else
        echo [$HOST_NAME] Syntax error\!
        exit 0
    fi
fi


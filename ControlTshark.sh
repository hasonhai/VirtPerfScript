#!/bin/bash
# Script to Start/Stop Tshark
# Usage: ./ControlTshark.sh start|stop [filename] [interface]
# Created by: Ha Son Hai (hasonhai124(at)gmail.com)

CONSOLE_OUTPUT="tshark$( date +%m%d ).console"
HOST_NAME=`hostname`

#Default filename:
if [ "$2" = "" ]; then
    FILENAME="traffic.cap"
    ITF="em2"
else
    FILENAME=$2
    if [ "$3" = "" ];then
        ITF="em2"
    else
        ITF=$3
    fi
fi

if [ "$1" = start ]; then
    echo $(date) $FILENAME >> $CONSOLE_OUTPUT
    if [ "" = "$( pidof tshark )" ]; then
        nohup tshark -i $ITF -f "tcp" -s 96 -w $FILENAME > /dev/null &>> $CONSOLE_OUTPUT &
        echo [$HOST_NAME] Tshark is started\!
    else
        echo [$HOST_NAME] There is runnung process. Kill All\!
        killall -q tshark #Quiet, don't talk
        sleep 1
        if [ "" = "$( pidof tshark )" ]; then
            echo [$HOST_NAME] Restarting Tshark...
            nohup tshark -i $ITF -f "tcp" -s 96 -w $FILENAME >/dev/null &>> $CONSOLE_OUTPUT &
            echo [$HOST_NAME] Tshark is started\!
        else
            echo [$HOST_NAME] Error\! Cannot kill them\!
            exit 0
        fi
    fi
else 
    if [ "$1" = stop ]; then
        TS=`pidof tshark`
        if [ -n "$TS" ]; then
            kill "$TS"
        fi
        sleep 1
        if [ "" = "$( pidof tshark )" ]; then
            echo [$HOST_NAME] Tshark is stopped\!
        else
            echo [$HOST_NAME] Error\! Cannot kill them\!
            exit 0
        fi        
    else
        echo [$HOST_NAME] Syntax error\!
        exit 0
    fi
fi


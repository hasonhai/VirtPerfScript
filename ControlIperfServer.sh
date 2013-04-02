#!/bin/bash
# Script to Start/Stop Iperf Server. Using for remote calling
# Usage: ./ControlIperfServer.sh start|stop
# Created by: Ha Son Hai (hasonhai124(at)gmail.com)

HOST_NAME=`hostname`
CONSOLE_OUTPUT="iperf$( date +%m%d ).console"
if [ "$1" = start ]; then
    if [ "" = "$(pidof iperf)" ]; then
        echo $(date) $FILENAME >> $CONSOLE_OUTPUT
        nohup iperf -s > /dev/null &>> $CONSOLE_OUTPUT &
        echo [$HOST_NAME] IPERF SERVER started\!
    else
        echo [$HOST_NAME] There is Iperf running. Kill Them All\!
        killall -q iperf #Quiet, don't talk
        sleep 1
        if [ "" = "$(pidof iperf)" ]; then
            echo [$HOST_NAME] Restarting Iperf Server...
            nohup iperf -s > /dev/null &>> $CONSOLE_OUTPUT &
            echo [$HOST_NAME] Iperf server started\!
        else
            echo [$HOST_NAME] Error\! Cannot kill them\!
            exit 0
        fi
    fi
else 
    if [ "$1" = stop ]; then
        IP=`pidof iperf`
        if [ -n "$IP" ]; then
            kill "$IP"
        fi
        sleep 1
        if [ "" = "$(pidof iperf)" ]; then
            echo [$HOST_NAME] Iperf Server is stopped\!
        else
            echo [$HOST_NAME] Error\! Cannot kill them\!
            exit 0
        fi 
    else
        echo [$HOST_NAME] Syntax error\!
        exit 0
    fi
fi


#!/bin/bash
# For running a collection of test at night
# Usage: ./NightRun.sh > /dev/null &> NightRun.console &

CHANGE_TCP_HTCP="sysctl -w net.ipv4.tcp_congestion_control=htcp"
CHANGE_TCP_VEGAS="sysctl -w net.ipv4.tcp_congestion_control=vegas"
CHANGE_TCP_VENO="sysctl -w net.ipv4.tcp_congestion_control=veno"
CHANGE_TCP_HIGHSPEED="sysctl -w net.ipv4.tcp_congestion_control=highspeed"
CHANGE_TCP_CUBIC="sysctl -w net.ipv4.tcp_congestion_control=cubic"
CHANGE_TCP_RENO="sysctl -w net.ipv4.tcp_congestion_control=reno"

CMD=ssh
CMD_OPTIONS="root@134.59.129.197"

#Test RENO
$CHANGE_TCP_RENO
$CMD $CMD_OPTIONS "$CHANGE_TCP_RENO"
for INCR in `seq 1 10`
do
   sleep 10
   sh RunTest.sh 32 tshark
done

ADDING_DELAY="tc qdisc add dev em2 root netem delay 200ms && echo Delay is added"
DEL_DELAY="tc qdisc del dev em2 root netem delay 200ms && echo Delay is removed"

$CMD $CMD_OPTIONS "$ADDING_DELAY"

$CHANGE_TCP_RENO
$CMD $CMD_OPTIONS "$CHANGE_TCP_RENO"
for INCR in `seq 1 10`
do
    sh RunTest.sh 32 tshark
    sleep 10
done

$CMD $CMD_OPTIONS "$DEL_DELAY"
echo Done\!

#!/bin/bash
# For running a collection of test at night
# Usage: ./RunMultiTest.sh > /dev/null &> RunMultiTest.console &

CHANGE_TCP_HTCP="sysctl -w net.ipv4.tcp_congestion_control=htcp"
CHANGE_TCP_VEGAS="sysctl -w net.ipv4.tcp_congestion_control=vegas"
CHANGE_TCP_VENO="sysctl -w net.ipv4.tcp_congestion_control=veno"
CHANGE_TCP_HIGHSPEED="sysctl -w net.ipv4.tcp_congestion_control=highspeed"
CHANGE_TCP_CUBIC="sysctl -w net.ipv4.tcp_congestion_control=cubic"
CHANGE_TCP_RENO="sysctl -w net.ipv4.tcp_congestion_control=reno"

CMD=ssh
SVR_OPTIONS="root@10.10.11.253"
CLT_OPTIONS="root@10.10.11.1"

#Test RENO
#$CMD $CLT_OPTIONS "$CHANGE_TCP_RENO"
#$CMD $SVR_OPTIONS "$CHANGE_TCP_RENO"

#for INCR in `seq 1 2`
#do
#   sleep 10
#   sh RunTestRemote.sh 32 tcpdump size 104857600 #100MBs 
#done

#for INCR in `seq 1 2`
#do
#    sleep 10
#    sh RunTestRemote.sh 32 tcpdump size 1073741824 #1GBs
#done

#for INCR in `seq 1 2`
#do
#    sleep 10
#    sh RunTestRemote.sh 32 tcpdump size 10737418240 #10GBs
#done

#Test CUBIC
#$CMD $CLT_OPTIONS "$CHANGE_TCP_CUBIC"
#$CMD $SVR_OPTIONS "$CHANGE_TCP_CUBIC"
#for INCR in `seq 1 2`
#do
#   sleep 10
#   sh RunTestRemote.sh 32 tcpdump size 104857600
#done

#for INCR in `seq 1 2`
#do
#   sleep 10
#   sh RunTestRemote.sh 32 tcpdump size 1073741824
#done

#for INCR in `seq 1 2`
#do
#   sleep 10
#   sh RunTestRemote.sh 32 tcpdump size 10737418240
#done

#Test Highspeed
#$CMD $CLT_OPTIONS "$CHANGE_TCP_HIGHSPEED"
#$CMD $SVR_OPTIONS "$CHANGE_TCP_HIGHSPEED"
#for INCR in `seq 1 2`
#do
#   sleep 10
#   sh RunTestRemote.sh 32 tcpdump size 104857600
#done

#for INCR in `seq 1 2`
#do
#   sleep 10
#   sh RunTestRemote.sh 32 tcpdump size 1073741824
#done

#for INCR in `seq 1 2`
#do
#   sleep 10
#   sh RunTestRemote.sh 32 tcpdump size 10737418240
#done

ADDING_DELAY="tc qdisc add dev em2 root netem delay 50ms && echo Delay is added"
DEL_DELAY="tc qdisc del dev em2 root netem delay 50ms && echo Delay is removed"

$CMD $SVR_OPTIONS "$ADDING_DELAY"

$CMD $CLT_OPTIONS "$CHANGE_TCP_RENO"
$CMD $SVR_OPTIONS "$CHANGE_TCP_RENO"
for INCR in `seq 1 7`
do
    sh RunTestRemote.sh 32 tcpdump
    sleep 10
done

$CMD $CLT_OPTIONS "$CHANGE_TCP_CUBIC"
$CMD $SVR_OPTIONS "$CHANGE_TCP_CUBIC"
for INCR in `seq 1 7`
do
    sh RunTestRemote.sh 32 tcpdump
    sleep 10
done

$CMD $CLT_OPTIONS "$CHANGE_TCP_HIGHSPEED"
$CMD $SVR_OPTIONS "$CHANGE_TCP_HIGHSPEED"
for INCR in `seq 1 7`
do
    sh RunTestRemote.sh 32 tcpdump
    sleep 10
done

$CMD $SVR_OPTIONS "$DEL_DELAY"
echo Done\!

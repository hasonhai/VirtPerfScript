#!/bin/bash
# For running a collection of test at night
# Usage: ./RunMultiTest.sh > /dev/null &> RunMultiTest.console &

CHANGE_TCP_HTCP="sysctl -w net.ipv4.tcp_congestion_control=htcp"
CHANGE_TCP_VEGAS="sysctl -w net.ipv4.tcp_congestion_control=vegas"
CHANGE_TCP_VENO="sysctl -w net.ipv4.tcp_congestion_control=veno"
CHANGE_TCP_HIGHSPEED="sysctl -w net.ipv4.tcp_congestion_control=highspeed"
CHANGE_TCP_CUBIC="sysctl -w net.ipv4.tcp_congestion_control=cubic"
CHANGE_TCP_RENO="sysctl -w net.ipv4.tcp_congestion_control=reno"

#####CONFIGURE EXPERIMENT################
CMD=ssh
SVR_OPTIONS="root@10.10.11.253"
CLT_OPTIONS="root@10.10.11.1"

TEST_RENO="true"
TEST_CUBIC="true"
TEST_HIGHSPEED="true"
TEST_DELAY="true"
TEST_NODELAY="true"
TEST_SIZE="false"   
DUMP_PROG="tcpdump" # or "tshark"
SIZE1=5368709120     # 5GBs
SIZE2=5368709120    # 5GBs
SIZE3=5368709120   # 5GBs
NO_TEST=1
NO_DELAY_TEST=3
NO_SIZE_TEST=1

#########################################
if [ "$TEST_NODELAY" = true ]; then
    if [ "$TEST_RENO" = true ]; then
        echo Test RENO: $NO_TEST times
        $CMD $CLT_OPTIONS "$CHANGE_TCP_RENO"
        $CMD $SVR_OPTIONS "$CHANGE_TCP_RENO"
        for INCR in `seq 1 $NO_TEST`
        do
            sh RunTestRemote.sh 32 $DUMP_PROG
            sleep 10
        done
    fi

    if [ "$TEST_CUBIC" = true ]; then
        echo Test CUBIC: $NO_TEST times
        $CMD $CLT_OPTIONS "$CHANGE_TCP_CUBIC"
        $CMD $SVR_OPTIONS "$CHANGE_TCP_CUBIC"
        for INCR in `seq 1 $NO_TEST`
        do
            sh RunTestRemote.sh 32 $DUMP_PROG
            sleep 10
        done
    fi

    if [ "$TEST_HIGHSPEED" = true ]; then
        echo Test HIGHSPEED: $NO_TEST times
        $CMD $CLT_OPTIONS "$CHANGE_TCP_HIGHSPEED"
        $CMD $SVR_OPTIONS "$CHANGE_TCP_HIGHSPEED"
        for INCR in `seq 1 $NO_TEST`
        do
            sh RunTestRemote.sh 32 $DUMP_PROG
            sleep 10
        done
    fi
fi
##########################################

if [ "$TEST_SIZE" = true ]; then
    if [ "$TEST_RENO" = true ]; then
        echo Test RENO with constant size
        $CMD $CLT_OPTIONS "$CHANGE_TCP_RENO"
        $CMD $SVR_OPTIONS "$CHANGE_TCP_RENO"
        echo Test size 100MBs: $NO_SIZE_TEST times
        for INCR in `seq 1 $NO_SIZE_TEST`
        do
            sleep 10
            sh RunTestRemote.sh 32 $DUMP_PROG size $SIZE1 
        done
        echo Test size 1GBs: $NO_SIZE_TEST times
        for INCR in `seq 1 $NO_SIZE_TEST`
        do
            sleep 10
            sh RunTestRemote.sh 32 $DUMP_PROG size $SIZE2
        done
        echo Test size 10GBs: $NO_SIZE_TEST times
        for INCR in `seq 1 $NO_SIZE_TEST`
        do
            sleep 10
            sh RunTestRemote.sh 32 $DUMP_PROG size $SIZE3
        done
    fi

#Test CUBIC
    if [ "$TEST_CUBIC" = true ]; then
        echo Test CUBIC with constant size
        $CMD $CLT_OPTIONS "$CHANGE_TCP_CUBIC"
        $CMD $SVR_OPTIONS "$CHANGE_TCP_CUBIC"
        echo Test size 100MBs: $NO_SIZE_TEST times
        for INCR in `seq 1 $NO_SIZE_TEST`
        do
            sleep 10
            sh RunTestRemote.sh 32 $DUMP_PROG size $SIZE1
        done
        echo Test size 1GBs: $NO_SIZE_TEST times
        for INCR in `seq 1 $NO_SIZE_TEST`
        do
            sleep 10
            sh RunTestRemote.sh 32 $DUMP_PROG size $SIZE2
        done
        echo Test size 10GBs: $NO_SIZE_TEST times
        for INCR in `seq 1 $NO_SIZE_TEST`
        do
            sleep 10
            sh RunTestRemote.sh 32 $DUMP_PROG size $SIZE3
        done
    fi

#Test Highspeed
    if [ "$TEST_HIGHSPEED" = true ]; then
        echo Test HIGHSPEED with constant size
        $CMD $CLT_OPTIONS "$CHANGE_TCP_HIGHSPEED"
        $CMD $SVR_OPTIONS "$CHANGE_TCP_HIGHSPEED"
        echo Test size 100MBs: $NO_SIZE_TEST times
        for INCR in `seq 1 $NO_SIZE_TEST`
        do
            sleep 10
            sh RunTestRemote.sh 32 $DUMP_PROG size $SIZE1
        done
        echo Test size 1GBs: $NO_SIZE_TEST times
        for INCR in `seq 1 $NO_SIZE_TEST`
        do
            sleep 10
            sh RunTestRemote.sh 32 $DUMP_PROG size $SIZE2
        done
        echo Test size 10GBs: $NO_SIZE_TEST times
        for INCR in `seq 1 $NO_SIZE_TEST`
        do
            sleep 10
            sh RunTestRemote.sh 32 $DUMP_PROG size $SIZE3
        done
    fi
fi

###################################
if [ "$TEST_DELAY" = true ]; then
    ADDING_DELAY="tc qdisc add dev em2 root netem delay 50ms && echo Delay is added"
    DEL_DELAY="tc qdisc del dev em2 root netem delay 50ms && echo Delay is removed"
 
    TUNING_RMEM="echo \"4096 87380 9437184\" > /proc/sys/net/ipv4/tcp_rmem && echo Tuning rmem"
    TUNING_WMEM="echo \"4096 16384 9437184\" > /proc/sys/net/ipv4/tcp_wmem && echo Tuning wmem"
   
    echo Adding Delay to $SVR_OPTIONS
    $CMD $SVR_OPTIONS "$ADDING_DELAY"
    $CMD $CLT_OPTIONS "$TUNING_RMEM"
    $CMD $SVR_OPTIONS "$TUNING_RMEM"
    $CMD $CLT_OPTIONS "$TUNING_WMEM"
    $CMD $SVR_OPTIONS "$TUNING_WMEM"
    
    echo Test RENO with DELAY: $NO_DELAY_TEST times
    if [ "$TEST_RENO" = true ]; then
        $CMD $CLT_OPTIONS "$CHANGE_TCP_RENO"
        $CMD $SVR_OPTIONS "$CHANGE_TCP_RENO"
        for INCR in `seq 1 $NO_DELAY_TEST`
        do
            sh RunTestRemote.sh 32 $DUMP_PROG
            sleep 10
        done
        fi
    echo Test CUBIC with DELAY: $NO_DELAY_TEST times
    if [ "$TEST_CUBIC" = true ]; then
        $CMD $CLT_OPTIONS "$CHANGE_TCP_CUBIC"
        $CMD $SVR_OPTIONS "$CHANGE_TCP_CUBIC"
        for INCR in `seq 1 $NO_DELAY_TEST`
        do
            sh RunTestRemote.sh 32 $DUMP_PROG
            sleep 10
        done
    fi
    echo Test HIGHSPEED with DELAY: $NO_DELAY_TEST times
    if [ "$TEST_HIGHSPEED" = true ]; then
        $CMD $CLT_OPTIONS "$CHANGE_TCP_HIGHSPEED"
        $CMD $SVR_OPTIONS "$CHANGE_TCP_HIGHSPEED"
        for INCR in `seq 1 $NO_DELAY_TEST`
        do
            sh RunTestRemote.sh 32 $DUMP_PROG
            sleep 10
        done
    fi
fi
#########################################
echo Reset configuration...
if [ "$TEST_DELAY" = true ]; then
    echo Removing delay
    $CMD $SVR_OPTIONS "$DEL_DELAY"
    TUNING_RMEM="echo \"4096 87380 716800\" > /proc/sys/net/ipv4/tcp_rmem && echo Return rmem"
    TUNING_WMEM="echo \"4096 16384 716800\" > /proc/sys/net/ipv4/tcp_wmem && echo Return wmem"
    $CMD $CLT_OPTIONS "$TUNING_RMEM"
    $CMD $CLT_OPTIONS "$TUNING_WMEM"
    # Only reset Client since Server is not affected by tunning
fi
echo "Returning default TCP verion (CUBIC)"
$CMD $CLT_OPTIONS "$CHANGE_TCP_CUBIC"
$CMD $SVR_OPTIONS "$CHANGE_TCP_CUBIC"
echo Done\!

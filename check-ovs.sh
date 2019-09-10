#!/bin/sh

# This script gives periodical information about the status of the OpenVSwitch bridge br0
# It is useful for debugging purposes

while :
do
    echo "Testing: ovs-vsctl show"
    ovs-vsctl show
    echo " "
    echo "Testing: ovs-ofctl dump-flows br0"
    ovs-ofctl dump-flows br0
    echo " "
    echo "Testing: ovs-ofctl dump-ports br0"
    ovs-ofctl dump-ports br0
    echo " "
    echo "Please type ^C to quit"
    sleep 1
done

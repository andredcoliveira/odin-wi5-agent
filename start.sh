#!/bin/sh

if [ $# != 1 ] || [ $1 -lt 1 ] || [ $1 -gt 253 ]; then
  echo -e "Usage: ${0} <agent_1-253>"
  exit 0
fi

echo "Starting agent #${1}"

echo "Cleaning old Click files"
rm mon*

## Variables
echo "Setting variables"
CTLIP=172.16.1.100                                # Controller IP address
SW="br0"                                          # Name of the OpenVSwitch bridge
OVS_VSCTL="/usr/bin/ovs-vsctl"                    # Command to be used to invoke openvswitch
OVS_CTL="/usr/share/openvswitch/scripts/ovs-ctl"

## Setting interfaces

## OVS
$OVS_CTL status >/dev/null 2>&1
if [ $? == 0 ]; then
  echo "Resetting OpenvSwitch"
  # Reset the configuration into a clean state
  $OVS_VSCTL emer-reset
else
  echo "Restarting OpenVSwitch"
  $OVS_CTL start --system-id=random
  $OVS_VSCTL emer-reset
fi

## Configure OpenVSwitch
# Configure the OpenFlow Controller
$OVS_VSCTL set-controller $SW tcp:$CTLIP:6633
# Display the resulting configurations
echo && $OVS_VSCTL show && echo

## Launch click
echo "Launching Click"
./click < click-align agent${1}.cli &    # This makes the alignment and calls Click at the same time

## OpenVSwitch Rules
# OpenFlow rules needed to make it possible for DHCP traffic to arrive to the Wi-5 odin controller
# It may happen that the data plane port is port 1 and the tap port is port 2
ovs-ofctl add-flow $SW in_port=2,dl_type=0x0800,nw_proto=17,tp_dst=67,actions=output:1,CONTROLLER
ovs-ofctl add-flow $SW in_port=1,dl_type=0x0800,nw_proto=17,tp_dst=68,actions=output:CONTROLLER,2
# It may happen that the data plane port is port 2 and the tap port is port 1
ovs-ofctl add-flow $SW in_port=1,dl_type=0x0800,nw_proto=17,tp_dst=67,actions=output:2,CONTROLLER
ovs-ofctl add-flow $SW in_port=2,dl_type=0x0800,nw_proto=17,tp_dst=68,actions=output:CONTROLLER,1

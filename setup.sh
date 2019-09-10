#!/bin/sh

if [ $# != 1 ] || [ $1 -lt 1 ] || [ $1 -gt 253 ]; then
  echo -e "Usage: ${0} <agent_1-253>"
  exit 0
fi

echo "Configuring agent #${1}"

rm mon* >/dev/null 2>&1

## Variables
echo "Setting variables"
CTLIP=172.16.1.100                                # Controller IP address
SW="br0"                                          # Name of the OpenVSwitch bridge
INT="br-wlan"
AGENTIP=172.16.0.${1}
TAP="tap0"                                        # tap port for connecting to the Internet
CHANNEL=13
OVS_VSCTL="/usr/bin/ovs-vsctl"                    # Command to be used to invoke openvswitch
OVS_CTL="/usr/share/openvswitch/scripts/ovs-ctl"

## Setting interfaces
echo "Setting interfaces"
ip addr add 172.16.0.${1}/16 dev $INT
ip link set wlan0 down
iw phy phy0 interface add mon0 type monitor
echo "Added mon0 interface"
iw phy phy0 interface add mon2 type monitor
echo "Added mon2 interface"
ip link set mon0 down
ip link set mon2 down
iwconfig mon0 mode monitor
iwconfig mon2 mode monitor
ip link set mon0 up
echo "mon0 is now up"
ip link set mon2 up
echo "mon2 is now up"
ip link set mon0 mtu 1532
ip link set mon2 mtu 1532
iw phy0 set channel $CHANNEL
echo "phy0 is now in channel $CHANNEL"
ip link set wlan0 up
echo "wlan0 is now up"

## OVS
$OVS_CTL status >/dev/null 2>&1
if [ $? == 0 ]; then
  echo "Stopping OpenvSwitch"
  # Reset the configuration into a clean state
  $OVS_VSCTL emer-reset
  $OVS_CTL stop
fi

# Clean the OpenVSwitch database
if [ -d "/etc/openvswitch" ]; then
  echo "OpenVSwitch folder already exists: cleaning OpenVSwitch database"
  rm /etc/openvswitch/*
else
  echo "OpenVSwitch folder created"
  mkdir /etc/openvswitch
fi
if [ -d "/var/run/openvswitch" ]; then
  rm /var/run/openvswitch/*
fi

# The next line is added in order to start the controller after stopping openvswitch
# read -p "Now you can launch the Wi-5 odin controller and press Enter" pause

# Launch OpenVSwitch
echo "Launching OpenVSwitch"
$OVS_CTL start --system-id=random

## Configure OpenVSwitch
# Create the bridge
$OVS_VSCTL add-br $SW
# Add the data plane port to OpenVSwitch
$OVS_VSCTL add-port $SW $INT
# Remove the ip address from the $INT and add it to the OpenVSwitch bridge $SW
ip addr flush dev $INT
#ip link set $INT down
ip addr add 172.16.0.${1}/16 dev $SW
ip link set $SW up
# Do the same for the default gateway
route add default gw 172.16.0.254 $SW && route del default gw 172.16.0.254 $INT
# Configure the OpenFlow Controller
$OVS_VSCTL set-controller $SW tcp:$CTLIP:6633
# Display the resulting configurations
echo && $OVS_VSCTL show && echo

# Add the 'TAP' interface to OpenVSwitch
echo "Adding Click interface '$TAP' to OVS"
ip tuntap add mode tap $TAP
ip link set $TAP up                # Putting the interface '$TAP' up
$OVS_VSCTL add-port $SW $TAP       # Adding 'TAP' interface (click Interface) to OVS

## OpenVSwitch Rules
# OpenFlow rules needed to make it possible for DHCP traffic to arrive to the Wi-5 odin controller
# It may happen that the data plane port is port 1 and the tap port is port 2
ovs-ofctl add-flow $SW in_port=2,dl_type=0x0800,nw_proto=17,tp_dst=67,actions=output:1,CONTROLLER
ovs-ofctl add-flow $SW in_port=1,dl_type=0x0800,nw_proto=17,tp_dst=68,actions=output:CONTROLLER,2
# It may happen that the data plane port is port 2 and the tap port is port 1
ovs-ofctl add-flow $SW in_port=1,dl_type=0x0800,nw_proto=17,tp_dst=67,actions=output:2,CONTROLLER
ovs-ofctl add-flow $SW in_port=2,dl_type=0x0800,nw_proto=17,tp_dst=68,actions=output:CONTROLLER,1

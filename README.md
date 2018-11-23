**Note**. You will find detailed information in this wiki: https://github.com/Wi5/odin-wi5/wiki

Odin agent
=========

Odin agents run on physical APs, and are implemented as Click elements. Agents contain the logic for the Wi-Fi split-MAC and LVAP handling. Agents also record information about clients using radiotap headers, and communicate with the Odin Master over the Odin control channel. The physical AP hosting the agent also requires a slightly modified Wi-Fi device driver to generate ACK frames for every LVAP that is hosted on the AP.


Source files for Odin agent:

src/odinagent{.cc,.hh}
-----------------

These are the Click OdinAgent element files. They've only been
tested in userspace mode so far. To build:

1. Add these files to <click>/elements/local/

2. Build Click with the `--enable-local` and `--enable-userlevel` flag.

3. ``` $ make```

agent-click-file-gen.py
-----------------------

Click file generator for the agent. Configure and use this script
to generate the appropriate Odin agent click file.

To see an example of how to use the python command, just use it without parameters:

`$ python agent-click-file-gen.py`

```
Usage:

agent-click-file-gen.py <AP_CHANNEL> <QUEUE_SIZE_IN> <QUEUE_SIZE_OUT> <MAC_ADDR_AP> <ODIN_MASTER_IP> <ODIN_MASTER_PORT> <DEBUGFS_FILE> <SSIDAGENT> <ODIN_AGENT_IP> <DEBUG_CLICK> <DEBUG_ODIN> <TX_RATE> <TX_POWER> <HIDDEN> <MULTICHANNEL_AGENTS> <DEFAULT_BEACON_INTERVAL> <BURST_BEACON_INTERVAL> <BURST> <MEASUREMENT_BEACON_INTERVAL> <CAPTURE_MODE> <MAC_CAPTURE>

AP_CHANNEL: it must be the same where mon0 of the AP is placed. To avoid problems at init time, it MUST be the same channel specified in the /etc/config/wireless file of the AP
QUEUE_SIZE_IN: you can use the size 500
QUEUE_SIZE_OUT: you can use the size 500
MAC_ADDR_AP: the MAC of the wireless interface mon0 of the AP. e.g. 60:E3:27:4F:C7:E1
ODIN_MASTER_IP is the IP of the openflow controller where Odin master is running
ODIN_MASTER_PORT should be 2819 by default
DEBUGFS_FILE is the path of the bssid_extra file created by the ath9k patch
             it can be /sys/kernel/debug/ieee80211/phy0/ath9k/bssid_extra
SSIDAGENT is the name of the SSID of this Odin agent
ODIN_AGENT_IP is the IP address of the AP where this script is running (the control plane ethernet IP, used for communicating with the controller)
DEBUG_CLICK: "0" no info displayed; "1" only basic info displayed; "2" all the info displayed
DEBUG_ODIN: "00" no info displayed; "01" only basic info displayed; "02" all the info displayed; "11" or "12": demo mode (more separators)
TX_RATE: it is an integer, and the rate is obtained by its product with 500kbps. e.g. if it is 108, this means 108*500kbps = 54Mbps
         we are not able to send packets at different rates, so a single rate has to be specified
TX_POWER: (in dBm). This is the power level of the main interface of the AP
          The value you put here does NOT modify the power level of the AP
          It just informs Odin Click module of the TX power value you have in the AP
          The AP will send this value to the controller as a part of the statistics
          For getting the value, use e.g. $# iw dev mon0 info, and put it here
HIDDEN: If HIDDEN is 1, then the AP will only send responses to the active scans targetted to the SSID of Odin
        If HIDDEN is 0, then the AP will also send responses to active scans with an empty SSID
MULTICHANNEL_AGENTS: If MULTICHANNEL_AGENTS is 1, it means that the APs can be in different channels
                     If MULTICHANNEL_AGENTS is 0, it means that all the APs are in the same channel
DEFAULT_BEACON_INTERVAL: Time between beacons (in milliseconds). Recommended values: 20-100
BURST_BEACON_INTERVAL: Time between beacons when a burst of CSAs is sent after a handoff (in milliseconds). Recommended values: 5-10
BURST: Number of beacons to send after add_lvap and channel_assigment. Recommended values: 5-40
MEASUREMENT_BEACON_INTERVAL: Time between measurement beacons (in milliseconds). Used for measuring the distance in dBs between APs. Recommended values: 20-100
CAPTURE_MODE: If CAPTURE_MODE is 1, two files will be generated, one for each interface, storing radiotap statistics
              If CAPTURE_MODE is 0, no statistic is storaged
MAC_CAPTURE: the MAC of the wireless interface in STA that will be monitorized. e.g. 60:E3:27:4F:C7:AA
              For capture all traffic: FF:FF:FF:FF:FF:FF

Example:
$ python agent-click-file-gen.py 9 500 500 74:f0:6d:20:d4:74 192.168.1.129 2819 /sys/kernel/debug/ieee80211/phy0/ath9k/bssid_extra wi5-demo 192.168.1.9 0 01 108 25 0 1 100 10 0 100 0 FF:FF:FF:FF:FF:FF > agent.cli

and then run the .cli file you have generated
click$ ./bin/click agent.cli
```
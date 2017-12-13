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

This is an example of how to use the python command:

    $ python agent-click-file-gen.py 4 500 500 14:CC:20:AC:72:91 192.168.1.129 2819 /sys/kernel/debug/ieee80211/phy0/ath9k/bssid_extra odin-unizar 192.168.1.7 0 11 12 25 0 1 100 10 5 100 0 FF:FF:FF:FF:FF:FF

where the parameters have the next meaning:

`4`			number of the channel

`500`			size of the input queue

`500`			size of the output queue

`14:CC:20:AC:72:91`	MAC address of the AP

`192.168.1.129`		IP address of the Controller

`2819`			port used to connect with the Controller

`/sys/kernel/debug/ieee80211/phy0/ath9k/bssid_extra`	directory of the debug file

`odin-unizar`		SSID

`192.168.1.7`		IP address of the AP

`0`			No click debug info

`11`			Debug level 1, with Demo appearance (1)

`12`			6 Mbps of TX rate

`25`            the Tx power of the AP is 25 dBm (obtained with `$iw dev mon0 info`)

`0`             no hidden mode: the AP will respond to all active scanning requests, even if they have no SSID name

`1`				multichannel agents: 0 if all the APs are in the same channel, 1 if not

`100`			default beacon interval: Time between beacons (in milliseconds)

`10`			burst beacon interval: Time between beacons when a burst of CSAs is sent after a handoff (in milliseconds)

`5`				burst: number of beacons in burst after add lvap or channel change

`100`			measurement beacon interval: Time between measurement beacons (in milliseconds). Used for measuring the distance in dBs between APs

`0`				capture mode: if enabled, two files will be generated, one for each interface, storing radiotap statistics

`FF:FF:FF:FF:FF:FF`		capture mac: the MAC of the wireless interface in STA that will be monitorized. For capture all traffic: FF:FF:FF:FF:FF:FF

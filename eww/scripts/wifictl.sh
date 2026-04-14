#!/bin/bash
# eww/scripts/wifictl.sh


NETLIST_BIN="./bin/get_netlist"

if [[ -z $(eww active-windows | grep 'wifictl') ]]; then
    # 1. Trigger scan in background (causes 1-sec lag spike once, now)
    nmcli device wifi rescan & 
    
    # 2. Open the window immediately
    eww open wifictl && eww update wifictlrev=true
    
    # 3. Force a data refresh so the list is current
    eww update network="$($NETLIST_BIN)"
else
    eww update wifictlrev=false
    eww update wificonfigrev=false
    (sleep 0.2 && eww close wifictl) &
fi
#!/bin/sh
# scripts/bluetooth/dualsense.sh

mac_address="D0:BC:C1:BA:59:DB"
connected=$(bluetoothctl info "$mac_address" | awk -F': ' '/Connected/ {print $2}')

if [[ "$connected" == "yes" ]]; then
    bluetoothctl disconnect $mac_address
else
    bluetoothctl connect $mac_address
fi

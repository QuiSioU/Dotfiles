#!/bin/sh
# scripts/bluetooth/headset.sh

mac_address="04:52:C7:5F:C7:42"
connected=$(bluetoothctl info "$mac_address" | awk -F': ' '/Connected/ {print $2}')

if [[ "$connected" == "yes" ]]; then
    bluetoothctl disconnect $mac_address
else
    bluetoothctl connect $mac_address
fi

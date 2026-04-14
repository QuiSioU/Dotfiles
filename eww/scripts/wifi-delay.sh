#!/bin/bash
# eww/scripts/wifi-delay.sh


/usr/bin/eww update wifihov=true
(sleep 0.45 && /usr/bin/eww update wifirev="$(/usr/bin/eww get wifihov)") &

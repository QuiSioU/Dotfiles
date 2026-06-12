#!/usr/bin/env bash
# eww/scripts/calendar.sh


if [[ -z $(eww active-windows | grep 'calendar') ]]; then
    eww open calendar && eww update calrev=true
else
    eww update calrev=false
    (sleep 0.2 && eww close calendar) &
fi

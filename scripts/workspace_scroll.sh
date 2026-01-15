#!/bin/bash

# Get the current workspace ID from Hyprland
current=$(hyprctl activeworkspace -j | jq '.id')

# Get the max non-empty workspace
actual_max=$(hyprctl workspaces -j | jq 'map(.id) | max')

# Compute max scrollable workspace
if [ "$actual_max" -lt 5 ]; then
    max_ws=5
else
    max_ws=$actual_max
fi

# Define your direction based on the argument passed
if [ "$1" == "up" ]; then
    if [ "$current" -lt "$max_ws" ]; then
        hyprctl dispatch workspace $((current + 1))
    fi
elif [ "$1" == "down" ]; then
    if [ "$current" -gt 1 ]; then
        hyprctl dispatch workspace $((current - 1))
    fi
fi

#!/bin/bash

# bash/bash_completions.sh

_bthdevs_auto_completions() {
    # Grab all MAC addresses of paired devices
    local mac_addresses_paired
    mac_addresses_paired=$(bluetoothctl devices Paired | awk '/^Device/{print $2}')

    # Tell bash to use them as completion options
    COMPREPLY=( $(compgen -W "$mac_addresses_paired" -- "${COMP_WORDS[1]}") )
}

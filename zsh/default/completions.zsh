#!/usr/bin/env zsh
# zsh/default/completions.zsh


_bthdevs_auto_completions() {
    # Grab all MAC addresses of paired devices as an array, with that extra parenthesis (...)
    _mac_addresses_paired=($(bluetoothctl devices Paired | awk '/^Device/{print $2}'))

    # Tell zsh to use them as completion options
    compadd -a _mac_addresses_paired
}

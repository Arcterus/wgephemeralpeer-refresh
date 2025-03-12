#!/bin/sh

uuid="wg$(printf %d\\n "0xf$(openssl rand -hex 3)")"

ifconfig "$1" -inet

ifconfig "$uuid" create
ifconfig "$uuid" wgkey "$(cat "$2")"
ifconfig "$uuid" wgpeer "$3" wgendpoint "$4" "$5" wgaip 10.64.0.1/32
ifconfig "$uuid" inet "$6"
ifconfig "$uuid" wgrtable 1
ifconfig "$uuid" up

mullvad-upgrade-tunnel -wg-interface "$uuid"
private="$(wg showconf "$uuid" | grep PrivateKey | cut -d'=' -f 2- | tr -d ' ')"
psk="$(wg showconf "$uuid" | grep PresharedKey | cut -d'=' -f 2- | tr -d ' ')"

ifconfig "$uuid" down
ifconfig "$uuid" destroy

ifconfig "$1" wgkey "$private"
ifconfig "$1" wgpeer "$3" wgpsk "$psk"
ifconfig "$1" inet "$6"
route add -net default "$(echo "$6" | cut -d'/' -f1)"

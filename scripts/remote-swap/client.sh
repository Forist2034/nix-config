#!/bin/sh

set -o errexit -o xtrace

readonly remote_ip="$1"
readonly remote_port="$2"
readonly path="$3"

nbd-client "$remote_ip" "$remote_port" "$path" -swap
swapon -o pri=10 "$path"

read -rsp $'Press any key to stop...\n' -n1 key

swapoff "$path"
sleep 8s # FIXME: avoid io error
nbd-client -d "$path"

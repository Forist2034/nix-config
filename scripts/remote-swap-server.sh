#!/bin/sh

set -o errexit -o xtrace

readonly listen="$1"
readonly size='16G'
readonly mount_path="$(mktemp --tmpdir -d remote-swap.XXXX)"
readonly swap_path="$mount_path/swap"

mount -t tmpfs -o size=$size none "$mount_path"
mkswap --file --size $size "$swap_path"
systemd-inhibit --why='Serving remote swap' nbd-server "$listen" -n "$swap_path" &

read -rsp $'Press any key to continue...\n' -n1 key
kill %1

umount "$mount_path"
rmdir "$mount_path"

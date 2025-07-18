#!/bin/sh

set -o errexit -o xtrace

readonly result_dir="$1"
readonly esp_part=/dev/disk/by-partlabel/sbc0-sd-esp
readonly root_part=/dev/disk/by-partlabel/sbc0-sd-root0

function write_boot() {
  # must set -F and -S, or the system can't boot
  mkfs.vfat -F 32 -S 512 -n sbc0-sd-esp -v $esp_part

  # timestamps in systemd-repart created image is too large for 32bit system
  local esp_img_mount=$(mktemp -d)
  local esp_part_mount=$(mktemp -d)
  mount -o ro,noatime $result_dir/install/install-image.esp.raw $esp_img_mount
  mount $esp_part $esp_part_mount
  cp -r --no-preserve=timestamps $esp_img_mount/* $esp_part_mount/
  umount $esp_img_mount
  umount $esp_part_mount
  rmdir $esp_img_mount
  rmdir $esp_part_mount
}

function write_root() {
  dd if=$result_dir/install/install-image.root.raw of=$root_part bs=4k status=progress
  sync
}

case $2 in
  boot)
    write_boot
    ;;
  root)
    write_root
    ;;
  "")
    write_boot
    write_root
    ;;
esac

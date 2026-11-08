#!/usr/bin/env bash

set -o errexit -o xtrace -o nounset

readonly disk="/dev/disk/by-id/ata-WDC_WD5000AAKX-00ERMA0_WD-WMC2E0NAJCPM"
readonly part="/dev/disk/by-partuuid/6165291c-7e0e-4d2f-90e3-2c69dd175a12"
readonly luks_dm="backup2-luks"
readonly luks_dev="/dev/mapper/$luks_dm"
readonly fs_dm="backup2-fs"
readonly fs_dev="/dev/mapper/$fs_dm"
readonly mount_path="/run/media/backup/backup2"

function mount_backup2() {
  mkdir -pv "$mount_path"
  integritysetup open "$part" "$luks_dm"
  cryptsetup open "$luks_dev" "$fs_dm"
  mount -o noexec,nodev,noatime "$fs_dev" "$mount_path"
}
function umount_backup2() {
  umount "$mount_path"
  cryptsetup close "$fs_dm"
  integritysetup close "$luks_dm"
}

case "$1" in
mount)
  mount_backup2
  ;;
umount)
  umount_backup2
  ;;
disconnect)
  sync
  udisksctl power-off --block-device "$disk"
  sleep 30s
  ;;
esac

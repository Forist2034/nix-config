#!/bin/sh

set -o errexit -o xtrace -o nounset

readonly image_dir="$1/image"
readonly esp_part=/dev/disk/by-partlabel/sbc0-sd-esp
readonly image_part=/dev/disk/by-partlabel/sbc0-sd-images

nix build --keep-going -j1 -L --out-link $image_dir \
    ${FLAKE}#nixosConfigurations.nixos-sbc0.config.system.build.images.ro-image

function image_filename() {
    jq -r "map(select(.label | startswith(\"$1\"))) | .[0].split_path" $image_dir/repart-output.json
}
readonly boot_info_file="$image_dir/$(image_filename "boot-info")"
readonly root_file="$image_dir/$(image_filename "sbc0-root")"

readonly info_mount=$(mktemp -d)
mount $boot_info_file $info_mount

function init_part() {
    # must set -F and -S, or the system can't boot
    mkfs.vfat -F 32 -S 512 -n sbc0-sd-esp -v $esp_part
    
    mkfs.ext4 -L sbc0-images $image_part
}

function write_boot() {
    local esp_part_mount=$(mktemp -d)
    mount $esp_part $esp_part_mount
    cp -r --no-preserve=timestamps $info_mount/boot/* $esp_part_mount/
    umount $esp_part_mount
    rmdir $esp_part_mount
}

function write_image() {
    local image_part_mount=$(mktemp -d)
    mount $image_part $image_part_mount
    cp $boot_info_file "$image_part_mount/$(jq -r '."boot-info"' $info_mount/filenames.json)"
    cp $root_file "$image_part_mount/$(jq -r .root $info_mount/filenames.json)"
    umount $image_part_mount
    rmdir $image_part_mount
}

case $2 in
    "reset")
        init_part
        write_boot
        write_image
        ;;
    "write")
        write_boot
        write_image
        ;;
    *)
        ;;
esac

umount $info_mount
rmdir $info_mount

#!/bin/sh

set -o errexit -o xtrace -o nounset

readonly image_dir="$1/image"
readonly remote="$2"

nix build --keep-going -j1 -L --out-link $image_dir \
    $FLAKE#nixosConfigurations.nixos-sbc0.config.system.build.images.ro-image

function image_filename() {
    jq -r "map(select(.label | startswith(\"$1\"))) | .[0].split_path" $image_dir/repart-output.json
}
readonly boot_info_file="$image_dir/$(image_filename "boot-info")"
readonly root_file="$image_dir/$(image_filename "sbc0-root")"

readonly info_mount=$(mktemp -d)
erofsfuse $boot_info_file $info_mount

scp $root_file root@$remote:/mnt/images/$(jq -r .root $info_mount/filenames.json)
scp $boot_info_file root@$remote:/mnt/images/$(jq -r '."boot-info"' $info_mount/filenames.json)

readonly uki_file=$(jq -r .uki $info_mount/filenames.json)
scp "$info_mount/boot/EFI/Linux/$uki_file" "root@$remote:/boot/EFI/Linux/$uki_file"

fusermount -u $info_mount
rmdir $info_mount
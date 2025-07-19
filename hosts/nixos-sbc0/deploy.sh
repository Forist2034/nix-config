#!/bin/sh

set -o errexit -o xtrace -o nounset

readonly result_dir=$1
readonly host=$2
readonly op=$3

nix build -L -j1 --keep-going --out-link $result_dir/system \
  ${FLAKE}#nixosConfigurations.nixos-sbc0.config.system.build.toplevel 
nix copy $result_dir/system --to ssh://root@$host
ssh root@$host $(readlink -f $result_dir/system)/bin/switch-to-configuration $op


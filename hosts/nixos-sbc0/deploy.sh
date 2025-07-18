#!/bin/sh

set -o errexit -o xtrace

nix build  .#nixosConfigurations.nixos-sbc0.config.system.build.toplevel  -L -j1 --keep-going --out-link $1/system
nix copy $1/system --to ssh://root@$2
ssh root@$2 $(readlink -f $1/system)/bin/switch-to-configuration $3


#!/bin/sh

set -o errexit -o xtrace -o nounset

readonly result_dir="$1"

function run_build() {
  nix build --keep-going -j1 -L --out-link $result_dir/$2 \
    ${FLAKE}#nixosConfigurations.nixos-sbc0.config.$1
}

function build_image() {
  run_build system.build.images.ro-image image
}
function build_install() {
  run_build system.build.images.install install
}
function build_system() {
  run_build system.build.toplevel system
}

case $2 in
  system)
    build_system
    ;;
  install)
    build_install
    ;;
  image)
    build_image
    ;;
  all)
    build_system
    build_install
    build_image
    ;;
  *)
    echo "unknown command $2"
    ;;
esac

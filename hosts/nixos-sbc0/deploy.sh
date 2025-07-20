#!/bin/sh

set -o errexit -o xtrace -o nounset

readonly result_dir=$1
readonly host=$2
readonly op=$3

nix copy $result_dir --to ssh://root@$host
ssh root@$host $(readlink -f $result_dir/system)/bin/switch-to-configuration $op


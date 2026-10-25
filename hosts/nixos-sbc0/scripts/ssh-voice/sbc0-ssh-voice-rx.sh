#!/bin/sh

set -o xtrace -o errexit

ssh nixos-sbc0 "arecord -D 'sysdefault:CARD=Codec' -r 16000 --format S16_LE -t raw -c 1 - \
    | opusenc --raw-bits 16 --raw-rate 16000 --raw-chan 1 --raw-endianness 0 - --max-delay 5 -" |
  pw-play --container oga -

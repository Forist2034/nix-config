#!/bin/sh

set -o xtrace -o errexit

pw-record --channels 1 --rate 16000 --format opus --container oga -q 0 - |
  ssh nixos-sbc0 "opusdec --force-wav - - | aplay --file-type wav -D 'sysdefault:CARD=Device' -"

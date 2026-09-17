#!/bin/sh

readonly dest="$2/$(date '+%Y-%m')"

mkdir -pv "$dest"
for f in "$1"/*; do
    mv -v "$f" "$dest"
done

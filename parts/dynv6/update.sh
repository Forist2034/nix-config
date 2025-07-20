#!/bin/sh

set -o errexit -o nounset -o pipefail

readonly zone="$1"
readonly device="$2"

function get_ip_addr() {
  ip -6 --json addr show dev $device scope global | \
    jq -r '.[0].addr_info | map(select((.local != null) and (.local | startswith("fd") | not))) | .[0].local'
}

readonly ip_addr=$(get_ip_addr)
echo "public ip address: $ip_addr"

curl "http://dynv6.com/api/update" \
  --url-query "hostname=$zone" \
  --url-query "token=$DYNV6_HTTP_TOKEN" \
  --url-query "ipv6=$ip_addr"


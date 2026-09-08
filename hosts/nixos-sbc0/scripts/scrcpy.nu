#!/usr/bin/env nu

const kdl_config = path self ./scrcpy.kdl
const adb_socket = "scrcpy_adb.sock"

export def main [] {
  ssh -P muxed nixos-sbc0 amixer --card 'Codec' cset "name='Mic1 Capture Switch'" on
  let socket_path = $adb_socket | path expand
  $env.ADB_SERVER_SOCKET = $"localfilesystem:($socket_path)"
  zellij --layout $kdl_config
  if ($socket_path | path exists) {
    rm $socket_path
  }
}

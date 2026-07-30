#!/usr/bin/env nu

const kdl_config = path self ./scrcpy.kdl
const adb_socket = "scrcpy_adb.sock"

export def main [] {
  ssh nixos-sbc0 amixer --card 'Codec' cset "name='Mic1 Capture Switch'" on
  zellij --layout $kdl_config
  if ($adb_socket | path exists) {
    rm $adb_socket
  }
}

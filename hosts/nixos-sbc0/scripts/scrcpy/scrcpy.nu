#!/usr/bin/env nu

const kdl_config = path self ./scrcpy.kdl
const ssh_voice = path self ../ssh-voice
const adb_socket = "scrcpy_adb.sock"

export def main [] {
  ssh -P muxed nixos-sbc0 amixer --card 'Codec' cset "name='Mic1 Capture Switch'" on
  let socket_path = $adb_socket | path expand
  $env.ADB_SERVER_SOCKET = $"localfilesystem:($socket_path)"
  $env.PATH = $env.PATH | prepend $ssh_voice
  zellij --layout $kdl_config
  if ($socket_path | path exists) {
    rm $socket_path
  }
}

libs: {
  bluetooth = (import ./bluetooth.nix) libs;
  firefox = (import ./firefox) libs;
  github = (import ./github) libs;
  ssh = (import ./ssh.nix) libs;
}

libs: {
  bluetooth = (import ./bluetooth.nix) libs;
  firefox = (import ./firefox) libs;
  github = (import ./github) libs;
  htop = (import ./htop) libs;
  gopass = (import ./gopass.nix) libs;
  gpg = (import ./gpg.nix) libs;
  ssh = (import ./ssh.nix) libs;
  thunderbird = (import ./thunderbird.nix) libs;
  vscode = (import ./vscode.nix) libs;
}

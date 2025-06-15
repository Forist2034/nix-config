libs: {
  bluetooth = (import ./bluetooth.nix) libs;
  firefox = (import ./firefox) libs;
  github = (import ./github) libs;
  htop = (import ./htop) libs;
  gpg = (import ./gpg.nix) libs;
  ssh = (import ./ssh.nix) libs;
  vscode = (import ./vscode.nix) libs;
}

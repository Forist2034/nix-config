args: {
  bluetooth = (import ./bluetooth.nix) args;
  dynv6 = (import ./dynv6) args;
  firefox = (import ./firefox) args;
  github = (import ./github) args;
  htop = (import ./htop) args;
  gopass = (import ./gopass.nix) args;
  gpg = (import ./gpg.nix) args;
  kwallet = (import ./kwallet.nix) args;
  nushell = (import ./nushell.nix) args;
  ssh = (import ./ssh.nix) args;
  taskwarrior = (import ./taskwarrior.nix) args;
  thunderbird = (import ./thunderbird.nix) args;
  vscode = (import ./vscode.nix) args;
}

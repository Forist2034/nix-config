args: {
  bluetooth = (import ./bluetooth.nix) args;
  direnv = (import ./direnv.nix) args;
  dynv6 = (import ./dynv6) args;
  firefox = (import ./firefox) args;
  forgejo = (import ./forgejo) args;
  github = (import ./github) args;
  htop = (import ./htop) args;
  gopass = (import ./gopass.nix) args;
  gpg = (import ./gpg.nix) args;
  input-method = (import ./input-method.nix) args;
  kwallet = (import ./kwallet.nix) args;
  libvirt = (import ./libvirt.nix) args;
  nushell = (import ./nushell.nix) args;
  openrgb = (import ./openrgb.nix) args;
  ssh = (import ./ssh.nix) args;
  task = (import ./task.nix) args;
  taskwarrior = (import ./taskwarrior.nix) args;
  thunderbird = (import ./thunderbird.nix) args;
  vscodium = (import ./vscodium.nix) args;
}

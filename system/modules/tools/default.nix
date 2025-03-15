{ modules, ... }@libs:
{ ... }:
{
  imports = modules.importWithLibs libs [
    ./gpg.nix
    ./ssh.nix
    ./gopass.nix
    ./taskwarrior.nix
  ];
}

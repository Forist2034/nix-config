{ modules, ... }@libs:
{ ... }:
{
  imports = modules.importWithLibs libs [
    ./gpg.nix
    ./gopass.nix
    ./taskwarrior.nix
  ];
}

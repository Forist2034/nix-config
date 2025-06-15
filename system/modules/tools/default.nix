{ modules, ... }@libs:
{ ... }:
{
  imports = modules.importWithLibs libs [
    ./gopass.nix
    ./taskwarrior.nix
  ];
}

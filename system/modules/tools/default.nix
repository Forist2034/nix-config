{ modules, ... }@libs:
{ ... }:
{
  imports = modules.importWithLibs libs [
    ./taskwarrior.nix
  ];
}

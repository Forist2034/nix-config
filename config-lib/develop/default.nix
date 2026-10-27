{ local-lib, inputs, ... }:
let
  devLib = {
    mkEnableModule =
      {
        name,
        descName,
      }:
      modConfig:
      {
        config,
        lib,
        pkgs,
        ...
      }@args:
      {
        options = {
          cfglib.develop.${name} = {
            enable = lib.mkEnableOption "${descName} support";
          };
        };
        config = lib.mkIf args.config.cfglib.develop.${name}.enable (modConfig args);
      };
  };
  mods = builtins.map (p: import p { inherit local-lib devLib inputs; }) [
    ./nickel.nix
    ./nix.nix
  ];
  collectMod =
    selector:
    let
      imports = builtins.filter (m: m != null) (builtins.map selector mods);
    in
    {
      inherit imports;
    };
in
{
  submodules = {
    vscodium = collectMod (m: m.submodules.vscodium or null);
    helix = collectMod (m: m.submodules.helix or null);
    firefox.global = collectMod (m: m.submodules.firefox.global or null);
  };
  nixvim = collectMod (m: m.nixvim or null);
  home = collectMod (m: m.home or null);
}

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
    ./agda.nix
    ./cmake.nix
    ./cpp.nix
    ./css.nix
    ./dhall.nix
    ./gradle.nix
    ./graphql.nix
    ./haskell.nix
    ./html.nix
    ./java.nix
    ./javascript.nix
    ./json.nix
    ./kotlin.nix
    ./latex.nix
    ./lean.nix
    ./lua.nix
    ./markdown.nix
    ./maven.nix
    ./meson.nix
    ./nickel.nix
    ./nix.nix
    ./nushell.nix
    ./ocaml.nix
    ./prettier.nix
    ./python.nix
    ./rocq.nix
    ./rust.nix
    ./scala.nix
    ./shell.nix
    ./stm32.nix
    ./toml.nix
    ./typescript.nix
    ./typst.nix
    ./verilog.nix
    ./zig.nix
  ];
  collectMod = selector: {
    imports = builtins.map (
      v:
      let
        r = selector v;
      in
      if r == null then
        { lib, ... }: {
          options = {
            cfglib.develop.${v.name} = {
              enable = lib.mkEnableOption "dummy option";
            };
          };
        }
      else
        r
    ) mods;
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

{ modules, ... }@libs:
let
  modules =
    libs.modules.importWithLibs (libs // { mkHomeModule = (import ./mkHomeModule.nix) libs; })
      [
        ./cmake.nix
        ./coq.nix
        ./cpp.nix
        ./dhall.nix
        ./graphql.nix
        ./haskell.nix
        ./latex.nix
        ./lean.nix
        ./lua.nix
        ./nickel.nix
        ./nix.nix
        ./ocaml.nix
        ./rust.nix
        ./scala.nix
        ./toml.nix
        ./typescript.nix
        ./typst.nix
        ./verilog.nix
        ./zig.nix
      ];
in
{
  system =
    { ... }:
    {
      imports = builtins.catAttrs "system" modules;
    };
  home =
    { ... }:
    {
      imports = builtins.catAttrs "home" modules;
    };
}

{ modules, ... }@libs:
let
  modules =
    libs.modules.importWithLibs (libs // { mkHomeModule = (import ./mkHomeModule.nix) libs; })
      [
        ./cmake.nix
        ./coq.nix
        ./cpp.nix
        ./css.nix
        ./dhall.nix
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
        ./nickel.nix
        ./nix.nix
        ./ocaml.nix
        ./prettier.nix
        ./python.nix
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

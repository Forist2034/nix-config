{ modules, ... }@libs:
let
  modules =
    libs.modules.importWithLibs (libs // { mkHomeModule = (import ./mkHomeModule.nix) libs; })
      [
        ./cmake.nix
        ./coq.nix
        ./cpp.nix
        ./dhall.nix
        ./haskell.nix
        ./latex.nix
        ./lua.nix
        ./nix.nix
        ./ocaml.nix
        ./rust.nix
        ./toml.nix
        ./typescript.nix
        ./typst.nix
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

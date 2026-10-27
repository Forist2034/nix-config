{ local-lib, ... }:
let
  modules =
    # TODO: use arguments directly
    local-lib.modules.importWithLibs local-lib [
      ./haskell.nix
      ./java.nix
      ./javascript.nix
      ./ocaml.nix
      ./rust.nix
      ./scala.nix
      ./typst.nix
      ./zig.nix
    ];
in
{
  system =
    { ... }:
    {
      imports = builtins.catAttrs "system" modules;
    };
}

flakes:
{ pkgs, ... }:
let
  collectInputs =
    path: flake:
    ''
      mkdir -pv "${path}"
      ln -sv "${flake}" "${path}/flake"
    ''
    + builtins.concatStringsSep "\n" (
      builtins.attrValues (
        builtins.mapAttrs (name: collectInputs "${path}/inputs/${name}") (flake.inputs or { })
      )
    );
in
pkgs.runCommand "flake-inputs" { } (
  builtins.concatStringsSep "\n" (
    builtins.attrValues (builtins.mapAttrs (name: flake: collectInputs "$out/${name}" flake) flakes)
  )
)

{
  self,
  lock,
}:
{ pkgs, ... }:
let
  nodes = builtins.attrValues (
    builtins.mapAttrs (name: node: ''
      ${if node ? locked then "ln -sv ${builtins.fetchTree node.locked} $out/nodes/${name}" else ""}
      cp ${builtins.toFile "${name}.json" (builtins.toJSON node)} $out/nodes/${name}.json
    '') lock.nodes
  );
in
pkgs.runCommand "flake-inputs" { } ''
  mkdir -pv $out/nodes

  ${builtins.concatStringsSep "\n" nodes}

  ln -sv ${self} $out/root
  cp ${builtins.toFile "lock.json" (builtins.toJSON lock)} $out/lock.json
''

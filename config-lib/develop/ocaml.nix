{ devLib, ... }:
let
  name = "ocaml";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "OCaml";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [ pkgs.vscode-extensions.ocamllabs.ocaml-platform ];
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      lsp.servers.ocamllsp = {
        enable = true;
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }: {
      home.packages = with pkgs; [
        ocaml
        opam
        dune_3
        dune-release
        ocamlformat
        ocamlPackages.ocaml-lsp
        ocamlPackages.merlin
        ocamlPackages.odoc
        ocamlPackages.utop
      ];
    }
  );
}

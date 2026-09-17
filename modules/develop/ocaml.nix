{
  persist,
  lib,
  options,
  vscodium,
  ...
}:
{
  system = persist.user.mkModule {
    name = "ocaml";
    options = {
      enable = lib.mkEnableOption "OCaml";
    };
    config = { value, ... }: lib.mkIf value.enable { directories = [ ".opam" ]; };
  };

  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        develop.ocaml = {
          enable = mkEnableOption "OCaml environment";

          env.enable = options.mkDisableOption "OCaml build tools";

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium ocaml support";
            nixvim.enable = mkEnableOption "NixVim ocaml support";
          };
        };
      };

      config =
        let
          cfg = config.develop.ocaml;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable (
            with pkgs;
            [
              ocaml
              opam
              dune_3
              dune-release
              ocamlformat
              ocamlPackages.ocaml-lsp
              ocamlPackages.merlin
              ocamlPackages.odoc
              ocamlPackages.utop
            ]
          );

          programs.vscodium = vscodium.mkSimpleConfig cfg.editor.vscodium {
            extensions = [ pkgs.vscode-extensions.ocamllabs.ocaml-platform ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            lsp.servers.ocamllsp = {
              enable = true;
            };
          };
        };
    };
}

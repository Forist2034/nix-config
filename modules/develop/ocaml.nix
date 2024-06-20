{
  persist,
  lib,
  options,
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
            vscode.enable = mkEnableOption "VSCode ocaml support";
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

          programs.vscode = lib.mkIf cfg.editor.vscode.enable {
            extensions = [ pkgs.vscode-extensions.ocamllabs.ocaml-platform ];
          };
        };
    };
}

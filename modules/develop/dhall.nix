{ options, vscode, ... }:
{
  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        develop.dhall = {
          enable = mkEnableOption "Dhall support";

          env.enable = options.mkDisableOption "Dhall tools";

          editor = {
            vscode = vscode.mkSimpleOption "VSCode Dhall support";
            helix.enable = mkEnableOption "Helix Dhall support";
            nixvim.enable = mkEnableOption "Neovim Dhall support";
          };
        };
      };

      config =
        let
          cfg = config.develop.dhall;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable (
            with pkgs;
            [
              dhall
              dhall-json
              dhall-yaml
            ]
          );

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = with pkgs.vscode-extensions; [
              dhall.vscode-dhall-lsp-server
              dhall.dhall-lang
            ];
            userSettings = {
              "vscode-dhall-lsp-server.executable" = "${pkgs.dhall-lsp-server}/bin/dhall-lsp-server";
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable { extraPackages = [ pkgs.dhall-lsp-server ]; };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.dhall_lsp_server = {
                enable = true;
              };
            };
          };
        };
    };
}

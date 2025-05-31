{
  persist,
  options,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "typst";
    options = {
      enable = lib.mkEnableOption "Typst";
    };
    config = { value, ... }: lib.mkIf value.enable { directories = [ ".cache/typst/packages" ]; };
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
        develop.typst = {
          enable = mkEnableOption "Typst support";

          env.enable = options.mkDisableOption "Typst build tools";

          editor = {
            vscode.enable = mkEnableOption "VSCode Typst support";
            nixvim.enable = mkEnableOption "Neovim nix typst support";
          };
        };
      };

      config =
        let
          cfg = config.develop.typst;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [
            pkgs.typst
            pkgs.typst-fmt
          ];

          programs.vscode = lib.mkIf cfg.editor.vscode.enable {
            extensions = [ pkgs.vscode-extensions.myriad-dreamin.tinymist ];
            userSettings = {
              "tinymist.serverPath" = "${pkgs.tinymist}/bin/tinymist";
            };
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.tinymist = {
                enable = true;
              };
              typst-vim = {
                enable = true;
              };
            };
          };
        };
    };
}

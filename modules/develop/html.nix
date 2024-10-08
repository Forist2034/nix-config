{ options, ... }:
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
        develop.html = {
          enable = mkEnableOption "HTML environment";

          editor = {
            vscode.enable = mkEnableOption "VSCode HTML support";
            helix.enable = mkEnableOption "Helix HTML support";
            nixvim.enable = mkEnableOption "Nixvim HTML support";
          };
        };
      };

      config =
        let
          cfg = config.develop.html;
        in
        lib.mkIf cfg.enable {
          develop.prettier = {
            enable = cfg.editor.vscode.enable || cfg.editor.nixvim.enable;
            editor = {
              vscode = lib.mkIf cfg.editor.vscode.enable {
                enable = true;
                languages.html = true;
              };
              nixvim = lib.mkIf cfg.editor.nixvim.enable {
                enable = true;
                languages.html = true;
              };
            };
          };

          programs.helix = lib.mkIf cfg.enable { extraPackages = [ pkgs.vscode-langservers-extracted ]; };

          programs.nixvim = lib.mkIf cfg.enable {
            plugins = {
              lsp.servers.html = {
                enable = true;
              };
            };
          };
        };
    };
}

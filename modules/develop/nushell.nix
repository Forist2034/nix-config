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
      options = {
        develop.nushell = {
          enable = lib.mkEnableOption "Nushell support";
          editor = {
            vscode = vscode.mkSimpleOption "Nushell";
            nixvim.enable = lib.mkEnableOption "Nixvim Nushell support";
          };
        };
      };
      config =
        let
          cfg = config.develop.nushell;
        in
        lib.mkIf cfg.enable {
          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = [ pkgs.vscode-extensions.thenuprojectcontributors.vscode-nushell-lang ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            lsp.servers.nushell.enable = true;
          };
        };
    };
}

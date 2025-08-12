{ options, vscode, ... }:
{
  home =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options = with lib; {
        develop.shell = {
          enable = mkEnableOption "Shell environment";
          env.enable = options.mkDisableOption "Shell tools";
          editor = {
            vscode = vscode.mkSimpleOption "VSCode shell support";
            nixvim.enable = mkEnableOption "Nixvim shell support";
          };
        };
      };

      config =
        let
          cfg = config.develop.shell;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [
            pkgs.shfmt
            pkgs.shellcheck
          ];

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = [ pkgs.vscode-extensions.mads-hartmann.bash-ide-vscode ];
            userSettings = {
              "bashIde.shellcheckPath" = "${pkgs.shellcheck}/bin/shellcheck";
              "bashIde.shfmt.path" = "${pkgs.shfmt}/bin/shfmt";
            };
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            lsp.servers.bashls.enable = true;
            extraPackages = [
              pkgs.shfmt
              pkgs.shellcheck
            ];
          };
        };
    };
}

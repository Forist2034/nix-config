{ options, vscode, ... }:
{
  home =
    {
      config,
      pkgs,
      inputs,
      lib,
      info,
      ...
    }:
    {
      options = with lib; {
        develop.python = {
          enable = mkEnableOption "Python environment";

          env.enable = options.mkDisableOption "Python build tools";

          editor = {
            vscode = vscode.mkSimpleOption "VSCode Python support";
            nixvim.enable = mkEnableOption "Nixvim Python support";
          };
        };
      };

      config =
        let
          cfg = config.develop.python;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [
            pkgs.python3
            pkgs.ruff
          ];

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = with pkgs.vscode-extensions; [
              ms-python.python
              ms-python.debugpy
              charliermarsh.ruff
            ];
            userSettings = {
              "python.languageServer" = "Jedi";
              "ruff.path" = [ "${pkgs.ruff}/bin/ruff" ];
            };
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.pylsp = {
                enable = true;
                settings.plugins = {
                  ruff = {
                    enabled = true;
                    executable = "${pkgs.ruff}/bin/ruff";
                  };
                };
              };
            };
          };
        };
    };
}

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
        develop.css = {
          enable = mkEnableOption "CSS environment";

          env.enable = options.mkDisableOption "scss";

          editor = {
            vscode.enable = mkEnableOption "VSCode CSS support";
            helix.enable = mkEnableOption "Helix CSS support";
            nixvim.enable = mkEnableOption "Nixvim CSS support";
          };
        };
      };

      config =
        let
          cfg = config.develop.css;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [
            pkgs.sass
            pkgs.lessc
          ];

          develop.prettier =
            let
              editor = cfg.editor;
            in
            {
              enable = editor.vscode.enable || editor.nixvim.enable;
              editor = {
                vscode = lib.mkIf editor.vscode.enable {
                  enable = true;
                  languages = {
                    css = true;
                    scss = true;
                    sass = true;
                    less = true;
                  };
                };
                nixvim = lib.mkIf editor.nixvim.enable {
                  enable = true;
                  languages = {
                    css = true;
                    scss = true;
                    sass = true;
                    less = true;
                  };
                };
              };
            };

          programs.helix = lib.mkIf cfg.editor.helix.enable {
            extraPackages = [ pkgs.vscode-langservers-extracted ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.cssls = {
                enable = true;
              };
            };
          };
        };
    };
}

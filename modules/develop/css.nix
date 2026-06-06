{ options, vscodium, ... }:
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
            vscodium = vscodium.mkSimpleOption "VSCodium CSS support";
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
              enable = editor.vscodium.enable || editor.nixvim.enable;
              editor = {
                vscodium = lib.mkIf editor.vscodium.enable {
                  enable = true;
                  profiles = vscodium.profile.mkEnableConfig {
                    enable = true;
                    languages = {
                      css = true;
                      scss = true;
                      sass = true;
                      less = true;
                    };
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

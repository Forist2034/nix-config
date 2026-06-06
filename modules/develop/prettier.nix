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
        develop.prettier = {
          enable = mkEnableOption "Prettier";

          env.enable = mkEnableOption "Prettier cli";

          editor =
            let
              langOpt = mkOption {
                description = "enabled language id";
                type = types.attrsOf types.bool;
                default = { };
              };
            in
            {
              vscodium = {
                enable = mkEnableOption "VSCodium Prettier support";
                profiles = vscodium.profile.mkOption {
                  enable = mkEnableOption "Prettier support";
                  languages = langOpt;
                };
              };
              nixvim = {
                enable = mkEnableOption "Nixvim Prettier support";
                languages = langOpt;
              };
            };
        };
      };

      config =
        let
          cfg = config.develop.prettier;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [ pkgs.nodePackages.prettier ];

          programs.vscodium = lib.mkIf cfg.editor.vscodium.enable {
            profiles = vscodium.profile.mkConfig cfg.editor.vscodium.profiles (
              value:
              lib.mkIf value.enable {
                extensions = [ pkgs.vscode-extensions.esbenp.prettier-vscode ];
                userSettings = lib.mkMerge (
                  builtins.attrValues (
                    builtins.mapAttrs (
                      id: enable:
                      lib.mkIf enable {
                        "[${id}]" = {
                          "editor.defaultFormatter" = "esbenp.prettier-vscode";
                        };
                      }
                    ) value.languages
                  )
                );
              }
            );
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins.none-ls.sources.formatting.prettierd = {
              enable = true;
              disableTsServerFormatter =
                let
                  langs = cfg.editor.nixvim.languages;
                in
                (langs.typescript or false)
                || (langs.typescriptreact or false)
                || (langs.javascript or false)
                || (langs.javascriptreact or false);
              settings = {
                filetypes = builtins.concatLists (
                  builtins.attrValues (
                    builtins.mapAttrs (id: enable: if enable then [ id ] else [ ]) cfg.editor.nixvim.languages
                  )
                );
              };
            };
          };
        };
    };
}

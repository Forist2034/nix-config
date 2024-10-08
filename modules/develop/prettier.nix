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
        develop.prettier = {
          enable = mkEnableOption "Prettier";

          env.enable = mkEnableOption "Prettier cli";

          editor =
            let
              editorCfg = name: {
                enable = mkEnableOption "${name} Prettier support";
                languages = mkOption {
                  description = "enabled language id";
                  type = types.attrsOf types.bool;
                  default = { };
                };
              };
            in
            {
              vscode = editorCfg "VSCode";
              nixvim = editorCfg "Nixvim";
            };
        };
      };

      config =
        let
          cfg = config.develop.prettier;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [ pkgs.nodePackages.prettier ];

          programs.vscode = lib.mkIf cfg.editor.vscode.enable {
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
                ) cfg.editor.vscode.languages
              )
            );
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins.none-ls.sources.formatting.prettierd = {
              enable = true;
              # TODO: set settings when supported
              # settings = {
              #   filetypes = lib.mkMerge (
              #     builtins.attrValues (
              #       builtins.mapAttrs (id: enable: lib.mkIf enable [ id ]) cfg.editor.nixvim.languages
              #     )
              #   );
              # };
            };
          };
        };
    };
}

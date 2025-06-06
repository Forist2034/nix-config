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
        develop.lua = {
          enable = mkEnableOption "Lua support";

          env = {
            enable = options.mkDisableOption "Lua build tools";
            lua.enable = mkEnableOption "Lua build tools";
            luajit.enable = mkEnableOption "Luajit tools";
          };

          editor = {
            vscode = vscode.mkSimpleOption "VSCode Lua support";
            helix.enable = mkEnableOption "Helix Lua support";
            nixvim.enable = mkEnableOption "Neovim Lua support";
          };
        };
      };

      config =
        let
          cfg = config.develop.lua;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable (
            lib.mkMerge [
              (lib.mkIf cfg.env.lua.enable [ pkgs.lua ])
              (lib.mkIf cfg.env.luajit.enable [ pkgs.luajit ])
            ]
          );

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = [ pkgs.vscode-extensions.sumneko.lua ];
            userSettings = {
              "Lua.codeLens.enable" = true;
              "Lua.hint.enable" = true;
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable { extraPackages = [ pkgs.lua-language-server ]; };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.lua_ls = {
                enable = true;
              };
            };
          };
        };
    };
}

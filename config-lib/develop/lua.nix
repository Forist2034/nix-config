{ devLib, ... }:
let
  name = "lua";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Lua";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule (
      { pkgs, ... }: {
        extraPackages = [ pkgs.lua-language-server ];
      }
    );
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [ pkgs.vscode-extensions.sumneko.lua ];
        userSettings = {
          "Lua.codeLens.enable" = true;
          "Lua.hint.enable" = true;
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { pkgs, ... }: {
      plugins = {
        lsp.servers.lua_ls = {
          enable = true;
        };
      };
    }
  );

  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        cfglib.develop.lua = {
          enable = mkEnableOption "Lua support";

          lua.enable = mkEnableOption "Lua build tools";
          luajit.enable = mkEnableOption "Luajit tools";
        };
      };

      config =
        let
          cfg = config.cfglib.develop.lua;
        in
        lib.mkIf cfg.enable {
          home.packages = (
            lib.mkMerge [
              (lib.mkIf cfg.lua.enable [ pkgs.lua ])
              (lib.mkIf cfg.luajit.enable [ pkgs.luajit ])
            ]
          );
        };
    };
}

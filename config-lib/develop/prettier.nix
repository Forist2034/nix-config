{ devLib, local-lib, ... }:
let
  name = "prettier";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Prettier";
  };

  opts = with local-lib.lib; {
    cfglib.develop.prettier = {
      enable = mkEnableOption "Prettier support";
      languages = mkOption {
        description = "enabled language id";
        type = types.attrsOf types.bool;
        default = { };
      };
    };
  };
in
{
  inherit name;

  submodules = {
    vscodium =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        options = opts;
        config =
          let
            cfg = config.cfglib.develop.prettier;
          in
          lib.mkIf cfg.enable {
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
                ) cfg.languages
              )
            );
          };
      };
  };

  nixvim = { config, lib, ... }: {
    options = opts;
    config =
      let
        cfg = config.cfglib.develop.prettier;
      in
      lib.mkIf cfg.enable {
        plugins.none-ls.sources.formatting.prettierd = {
          enable = true;
          disableTsServerFormatter =
            let
              langs = cfg.languages;
            in
            (langs.typescript or false)
            || (langs.typescriptreact or false)
            || (langs.javascript or false)
            || (langs.javascriptreact or false);
          settings = {
            filetypes = builtins.concatLists (
              builtins.attrValues (builtins.mapAttrs (id: enable: if enable then [ id ] else [ ]) cfg.languages)
            );
          };
        };
      };
  };

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = [ pkgs.prettier ];
    }
  );
}

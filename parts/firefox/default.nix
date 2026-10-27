{
  local-lib,
  lib,
  ...
}:
let
  config = import ./config.nix;
in
{
  system =
    let
      modules = {
        persist = local-lib.persist.user.mkModule {
          name = "firefox";
          options = {
            enable = lib.mkEnableOption "Persist firefox data";
            configPath = lib.mkOption {
              description = "firefox config path";
              type = lib.types.pathWith { };
              default = ".config/mozilla/firefox";
            };
            profiles = local-lib.firefox.profile.mkOption {
              enable = lib.mkEnableOption "Persist profile";
              bookmarks.enable = lib.mkEnableOption "Persist bookmarks";
              bookmarkbackups.enable = lib.mkEnableOption "Persist bookmark backups";
              account.enable = lib.mkEnableOption "Persist firefox account";
            };
          };
          config =
            { value, ... }:
            let
              configPath = value.configPath;
            in
            lib.mkIf value.enable (
              lib.mkMerge (
                builtins.attrValues (
                  builtins.mapAttrs (
                    name: value:
                    lib.mkIf value.enable (
                      lib.mkMerge [
                        (lib.mkIf value.bookmarks.enable {
                          files = [
                            "${configPath}/${name}/places.sqlite"
                            "${configPath}/${name}/places.sqlite-shm"
                            "${configPath}/${name}/places.sqlite-wal"
                          ];
                        })
                        (lib.mkIf value.bookmarkbackups.enable {
                          directories = [ "${configPath}/${name}/bookmarkbackups" ];
                        })
                        (lib.mkIf value.account.enable {
                          files = [
                            "${configPath}/${name}/key4.db"
                            "${configPath}/${name}/signedInUser.json"
                            "${configPath}/${name}/logins.json"
                          ];
                        })
                      ]
                    )
                  ) (value.profiles or { })
                )
              )
            );
        };
      };
    in
    {
      inherit modules;

      default = modules.persist;
    };

  home = {
    default =
      {
        inputs,
        cfglib,
        lib,
        pkgs,
        info,
        ...
      }@args:
      let
        firefoxBackupPath = "${args.config.home.homeDirectory}/Documents/Restore Firefox";
      in
      {
        imports = [ cfglib.programs.firefox.home.default ];
        programs.firefox =
          let
            utils = inputs.browser-utils.packages.${info.system};
          in
          {
            configPath = "${args.config.xdg.configHome}/mozilla/firefox";

            nativeMessagingHosts = [ utils.browser-utils.ext ];

            profiles.default = lib.mkMerge [
              config.profiles.default
              {
                path = "default";

                settings = {
                  "xpinstall.signatures.required" = false;

                  "browser.backup.location" = firefoxBackupPath;
                };

                extensions = {
                  force = true;
                  packages = [ utils.history-extension ];
                  settings = {
                    "${utils.history-extension.addonId}".settings = {
                      root = "${args.config.home.homeDirectory}/Documents/browser-utils/history";
                    };
                  };
                };
              }
            ];
          };
        systemd.user = {
          services.firefox-keep-backup = {
            Unit.Description = "Keep firefox backup";
            Service = {
              ExecStart = lib.escapeShellArgs [
                ./move-backup.sh
                firefoxBackupPath
                "${args.config.home.homeDirectory}/Documents/backup/firefox/backup/html"
              ];
            };
          };
          paths.firefox-keep-backup = {
            Unit.Description = "Firefox backup dir path";
            Path = {
              PathChanged = [ firefoxBackupPath ];
              MakeDirectory = true;
            };
            Install.WantedBy = [ "default.target" ];
          };
        };
      };
  };
}

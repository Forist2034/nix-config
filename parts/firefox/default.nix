{
  local-lib,
  lib,
  ...
}:
let
  config = import ./config.nix;
in
{
  inherit config;

  system =
    let
      modules = {
        persist = local-lib.persist.user.mkModule {
          name = "firefox";
          options = {
            enable = lib.mkEnableOption "Persist firefox data";
            profiles = local-lib.firefox.profile.mkOption {
              enable = lib.mkEnableOption "Persist profile";
              bookmarks.enable = lib.mkEnableOption "Persist bookmarks";
              bookmarkbackups.enable = lib.mkEnableOption "Persist bookmark backups";
              account.enable = lib.mkEnableOption "Persist firefox account";
            };
          };
          config =
            { value, ... }:
            lib.mkIf value.enable (
              lib.mkMerge (
                builtins.attrValues (
                  builtins.mapAttrs (
                    name: value:
                    lib.mkIf value.enable (
                      lib.mkMerge [
                        (lib.mkIf value.bookmarks.enable {
                          files = [ ".mozilla/firefox/${name}/places.sqlite" ];
                        })
                        (lib.mkIf value.bookmarkbackups.enable {
                          directories = [ ".mozilla/firefox/${name}/bookmarkbackups" ];
                        })
                        (lib.mkIf value.account.enable {
                          files = [
                            ".mozilla/firefox/${name}/key4.db"
                            ".mozilla/firefox/${name}/signedInUser.json"
                            ".mozilla/firefox/${name}/logins.json"
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
      { ... }:
      {
        programs.firefox = {
          enable = true;
          policies = config.policies.base;
          profiles = {
            default = config.profiles.default // {
              isDefault = true;
            };
            test = config.profiles.base // {
              id = 1;
            };
          };
        };
      };

  };
}

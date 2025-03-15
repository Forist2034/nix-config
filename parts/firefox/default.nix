{
  persist,
  firefox,
  lib,
  options,
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
        persist = persist.user.mkModule {
          name = "firefox";
          options = {
            enable = lib.mkEnableOption "Persist firefox data";
            profiles = firefox.profile.mkOption {
              enable = lib.mkEnableOption "Persist profile";
              bookmarks.enable = options.mkDisableOption "Persist bookmarks";
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
                          directories = [ ".mozilla/firefox/${name}/bookmarkbackups" ];
                          files = [ ".mozilla/firefox/${name}/places.sqlite" ];
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

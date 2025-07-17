{
  local-lib,
  lib,
  ...
}:
{
  system =
    let
      modules = {
        persist = local-lib.persist.user.mkModule {
          name = "thunderbird";
          options = with lib; {
            enable = mkEnableOption "Persist thunderbird";
            profiles = mkOption {
              type = types.attrsOf (
                types.submodule {
                  options = {
                    enable = mkEnableOption "Persist profile";
                    mail.enable = local-lib.options.mkDisableOption "Persist mail";
                  };
                }
              );
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
                        (lib.mkIf value.mail.enable {
                          directories = [
                            ".thunderbird/${name}/ImapMail"
                            ".thunderbird/${name}/Mail"
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

  home =
    let
      profiles = {
        default =
          { ... }:
          {
            programs.thunderbird = {
              enable = true;
              profiles = {
                default = {
                  isDefault = true;
                };
              };
              settings = {
                # only allow cookies from visited site, for oauth2 login
                "network.cookie.cookieBehavior" = 3;
                "places.history.enabled" = false; # disable history
              };
            };
          };
      };
    in
    {
      inherit profiles;

      default = profiles.default;
    };
}

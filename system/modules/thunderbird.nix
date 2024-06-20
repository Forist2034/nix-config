{
  persist,
  lib,
  options,
  ...
}:
persist.user.mkModule {
  name = "thunderbird";
  options = with lib; {
    enable = mkEnableOption "Persist thunderbird";
    profiles = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkEnableOption "Persist profile";
            mail.enable = options.mkDisableOption "Persist mail";
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
}

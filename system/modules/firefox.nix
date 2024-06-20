{
  persist,
  firefox,
  lib,
  options,
  ...
}:
persist.user.mkModule {
  name = "firefox";
  options = {
    enable = lib.mkEnableOption "Persist firefox data";
    profiles = firefox.profile.mkOption {
      enable = lib.mkEnableOption "Persist profile";
      bookmarks.enable = options.mkDisableOption "Persist bookmarks";
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
              ]
            )
          ) (value.profiles or { })
        )
      )
    );
}

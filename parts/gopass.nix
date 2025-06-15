{ persist, lib, ... }:
{
  system =
    let
      modules = {
        persist = persist.user.mkModule {
          name = "gopass";
          options = {
            enable = lib.mkEnableOption "Gopass store";
          };
          config = { value, ... }: lib.mkIf value.enable { directories = [ ".local/share/gopass/stores" ]; };
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
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {
            xdg.configFile."gopass/config".text = lib.generators.toINI { } {
              core = {
                autopush = false;
                autosync = false;
              };
              mounts.path = "${config.xdg.dataHome}/gopass/stores/root";
            };

            home.packages = [ pkgs.gopass ];
          };
      };
    in
    {
      inherit profiles;
      default = profiles.default;
    };
}

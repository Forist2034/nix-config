{ local-lib, lib, ... }:
{
  system =
    let
      modules = {
        persist = local-lib.persist.system.mkModule {
          name = "openrgb";
          options = {
            enable = lib.mkEnableOption "OpenRGB support";
          };
          config =
            { value, lib, ... }:
            lib.mkIf value.enable {
              directories = [
                "/var/lib/OpenRGB"
              ];
            };
        };
      };
    in
    {
      inherit modules;

      default =
        { pkgs, ... }:
        {
          imports = [ modules.persist ];

          services.hardware.openrgb = {
            enable = true;
          };
        };
    };
}

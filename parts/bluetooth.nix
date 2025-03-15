{ persist, lib, ... }:
{
  system =
    let
      modules = {
        persist = persist.system.mkModule {
          name = "bluetooth";
          options = {
            enable = lib.mkEnableOption "Persist bluetooth";
          };
          config =
            { value, lib, ... }:
            lib.mkIf value.enable {
              directories = [
                {
                  directory = "/var/lib/bluetooth";
                  mode = "0700";
                }
              ];
            };
        };
      };
    in
    {
      inherit modules;

      default =
        { ... }:
        {
          imports = [
            modules.persist
          ];

          hardware.bluetooth = {
            enable = true;
          };
        };
    };
}

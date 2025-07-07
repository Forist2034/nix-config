{ persist, lib, ... }:
{
  system =
    let
      modules = {
        persist = persist.user.mkModule {
          name = "kwallet";
          options = {
            enable = lib.mkEnableOption "Kwallet";
          };
          config =
            { value, ... }:
            lib.mkIf value.enable {
              directories = [ ".local/share/kwalletd" ];
            };
        };
      };
    in
    {
      inherit modules;

      default = modules.persist;
    };
}

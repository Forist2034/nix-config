{ persist, lib, ... }:
{
  system =
    let
      modules = {
        persist = persist.user.mkModule {
          name = "gpg";
          options = {
            enable = lib.mkEnableOption "GnuPG persist";
          };
          config =
            { value, ... }:
            lib.mkIf value.enable {
              directories = [
                {
                  directory = ".gnupg";
                  mode = "0700";
                }
              ];
            };
        };
      };
    in
    {
      inherit modules;
      default = modules.persist;
    };

  home = {
    default =
      { pkgs, ... }:
      {
        programs.gpg = {
          enable = true;
        };
        services.gpg-agent = {
          enable = true;
          pinentry.package = pkgs.pinentry-all;
        };
      };
  };
}

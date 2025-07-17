{ local-lib, lib, ... }:
{
  system =
    let
      modules = {
        persist = local-lib.persist.system.mkModule {
          name = "ssh";
          options = {
            enable = lib.mkEnableOption "Persist system ssh";
            hostKeys = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "ssh host keys to persist";
            };
          };
          config =
            { value, lib, ... }:
            lib.mkIf value.enable {
              files = builtins.concatMap (k: [
                "/etc/ssh/${k}"
                "/etc/ssh/${k}.pub"
              ]) value.hostKeys;
            };
        };
      };
      profiles = {
        default =
          { ... }:
          {
            services.openssh = {
              enable = true;
              settings = {
                PermitRootLogin = "no";
                PasswordAuthentication = false;
              };
            };
          };
      };
    in
    {
      inherit modules profiles;
      default =
        { ... }:
        {
          imports = [
            modules.persist
            profiles.default
          ];
        };
    };
}

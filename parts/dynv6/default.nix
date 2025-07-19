{ local-lib, lib, ... }:
{
  system =
    let
      modules = {
        persist = local-lib.persist.system.mkModule {
          name = "update-dynv6";
          options = {
            enable = lib.mkEnableOption "Update dynv6 token";
          };
          config =
            { value, lib, ... }:
            lib.mkIf value.enable {
              directories = [ "/etc/update-dynv6" ];
            };
        };
        update-service =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {
            options = with lib; {
              services.update-dynv6 = {
                enable = mkEnableOption "Update dynv6";
                hostName = mkOption {
                  description = "host name to update";
                  type = types.str;
                };
              };
            };

            config =
              let
                cfg = config.services.update-dynv6;
              in
              lib.mkIf cfg.enable {
                systemd.services."update-dynv6@" = {
                  description = "Update dynv6 ddns record at %i";
                  path = [
                    pkgs.jq
                    pkgs.curl
                    pkgs.iproute2
                  ];
                  serviceConfig = {
                    Type = "oneshot";

                    ExecStart = "${./update.sh} ${cfg.hostName} %i";

                    EnvironmentFile = "/etc/update-dynv6/token.env";

                    User = "update-dynv6";
                    Group = "update-dynv6";
                    DynamicUser = true;
                    NoNewPrivileges = true;

                    ProtectSystem = "full";
                    ProtectHome = true;
                    PrivateDevices = true;
                    PrivateTmp = true;
                    PrivateUsers = true;
                  };
                };
              };
          };
      };
    in
    {
      default =
        { ... }:
        {
          imports = [
            modules.persist
            modules.update-service
          ];
        };
    };
}

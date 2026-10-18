{
  system =
    {
      lib,
      inputs,
      info,
      services,
      users,
      ...
    }:
    {
      containers.xray-proxy = {
        bindMounts = {
          unix-export = {
            hostPath = "/run/nixos-container/xray-proxy/unix-export";
            mountPoint = "/run/host/unix-export";
            isReadOnly = false;
          };
          proxy-cli = {
            hostPath = "/nix/persist/xray-proxy/home/reid/proxy-cli";
            mountPoint = "/home/reid/.local/share/proxy-cli";
            isReadOnly = false;
          };
        };
        config = { pkgs, ... }: {
          imports = [
            services.openssh.system.profiles.default
            users.reid.system.profiles.base
          ];

          environment.systemPackages = with pkgs; [
            xray
            v2ray-domain-list-community
            v2ray-geoip

            nickel

            inputs.proxy-cli.packages.${info.system}.default
          ];

          system.stateVersion = lib.trivial.release;
        };
      };

      systemd.services."container@xray-proxy" = {
        serviceConfig = {
          RuntimeDirectory = [ "nixos-container/%i/unix-export" ];
        };
      };
    };
}

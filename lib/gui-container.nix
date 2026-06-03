{
  name,
  gpu ? false,
  home ? false,
  config,
}:
{ services, lib, ... }:
{
  imports = [ (config.system name) ];

  containers.${name} = lib.mkMerge [
    {
      bindMounts = lib.mkMerge [
        {
          waylandDisplay = rec {
            hostPath = "/run/user";
            mountPoint = "/mnt/host${hostPath}";
            isReadOnly = true;
          };
          x11Display = rec {
            hostPath = "/tmp/.X11-unix";
            mountPoint = "/mnt/host${hostPath}";
            isReadOnly = true;
          };
          unixExport = {
            hostPath = "/run/nixos-container/${name}/unix-export";
            mountPoint = "/run/host/unix-export";
            isReadOnly = false;
          };
        }
        (lib.mkIf gpu {
          "/dev/dri" = {
            hostPath = "/dev/dri";
            isReadOnly = true;
          };
        })
        (lib.mkIf home {
          home = {
            hostPath = "/run/nixos-container/${name}/home";
            mountPoint = "/home";
            isReadOnly = false;
          };
        })
      ];
      allowedDevices = lib.mkIf gpu [
        {
          node = "char-drm";
          modifier = "rw";
        }
      ];

      config =
        { pkgs, ... }:
        {
          imports = [
            services.openssh.system.profiles.default
          ];

          hardware.graphics.enable = lib.mkIf gpu true;

          services.openssh.settings = {
            AcceptEnv = [
              "DISPLAY"
              "WAYLAND_DISPLAY"
            ];
            X11Forwarding = true;
          };

          environment.systemPackages = [ pkgs.xorg.xauth ];

          system.stateVersion = lib.trivial.release;
        };
    }
    (config.container name)
  ];

  systemd.services."container@${name}" = {
    serviceConfig = {
      RuntimeDirectory = lib.mkMerge [
        [
          "nixos-container/%i/unix-export"
        ]
        (lib.mkIf home [ "nixos-container/%i/home" ])
      ];
    };
  };
}

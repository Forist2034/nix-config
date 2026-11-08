{
  users,
  private,
  services,
  info,
  local-lib,
  suites,
  ...
}:
{
  imports = [
    suites.proxy.system
  ];

  containers = {
    # proxy-capture = {
    #   bindMounts = {
    #     unixExport = {
    #       hostPath = "/run/nixos-container/proxy-capture/unix-export";
    #       mountPoint = "/run/host/unix-export";
    #       isReadOnly = false;
    #     };
    #   };

    #   privateNetwork = true;
    #   enableTun = true;
    #   hostAddress6 = "fde0:9036:4433:10::1";
    #   localAddress6 = "fde0:9036:4433:10::2";
    #   forwardPorts = [
    #     {
    #       protocol = "tcp";
    #       hostPort = 8080;
    #     }
    #   ];

    #   config =
    #     { pkgs, lib, ... }:
    #     {
    #       imports = [
    #         services.openssh.system.profiles.default

    #         users.reid.system.profiles.base
    #       ];

    #       environment.systemPackages = [
    #         pkgs.socat
    #         pkgs.tun2socks
    #       ];

    #       networking.nameservers = [
    #         "fde0:9036:4433:20::1"
    #       ];

    #       system.stateVersion = lib.trivial.release;
    #     };
    # };
  };

  systemd.services."container@proxy-capture" = {
    serviceConfig = {
      RuntimeDirectory = [
        "nixos-container/%i/unix-export"
      ];
    };
  };

  # networking = {
  #   hosts = {
  #     "fde0:9036:4433::2" = [ "proxy-capture" ];
  #   };
  #   networkmanager.ensureProfiles = {
  #     profiles = {
  #       vm-proxy-capture = {
  #         connection = {
  #           id = "Vm-Proxy-Capture";
  #           type = "ethernet";
  #           interface-name = "vm-proxy-rec";
  #           uuid = "ca1be93b-cdd5-4ba3-86e8-09d85cc60394";
  #         };
  #         ipv4.method = "disabled";
  #         ipv6 = {
  #           method = "manual";
  #           address1 = "fde0:9036:4433::1/64";
  #         };
  #       };
  #     };
  #   };
  # };

  microvm.vms = {
    # proxy-capture = {
    #   config =
    #     { pkgs, lib, ... }:
    #     {

    #       imports = [
    #         services.openssh.system.profiles.default

    #         users.reid.system.profiles.base
    #       ];

    #       fileSystems."/" = {
    #         device = "none";
    #         fsType = "tmpfs";
    #         options = [
    #           "size=128M"
    #           "mode=755"
    #         ];
    #       };

    #       security.sudo.wheelNeedsPassword = false;

    #       services.redsocks = {
    #         enable = true;
    #         redsocks = [
    #           {
    #             type = "socks5";
    #             proxy = "[fde0:9036:4433::1]:8192";
    #           }
    #         ];
    #       };

    #       environment.systemPackages = [
    #         pkgs.mitmproxy
    #       ];

    #       microvm = {
    #         vcpu = 4;

    #         balloon = true;
    #         mem = 2 * 1024;

    #         vsock.cid = 128;
    #         interfaces = [
    #           {
    #             type = "tap";
    #             id = "vm-proxy-rec";
    #             mac = "02:00:00:00:00:7f";
    #           }
    #         ];

    #         writableStoreOverlay = "/nix/.rw-store";
    #         shares = [
    #           {
    #             proto = "9p";
    #             tag = "host-store";
    #             source = "/nix/store";
    #             mountPoint = "/nix/.ro-store";
    #           }
    #         ];
    #       };

    #       system.stateVersion = lib.trivial.release;
    #     };
    # };
  };
}

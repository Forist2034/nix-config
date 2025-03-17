{
  pkgs,
  system,
  graphical,
  modules,
  home,
  inputs,
  user,
  info,
  parts,
  suites,
  services,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    suites.develop.system

    parts.bluetooth.system.default

    services.openssh.system.default
  ];

  boot.loader = {
    systemd-boot.enable = true;
  };

  networking = {
    hostName = "nixos-desktop0";
    networkmanager.enable = true;
  };

  services.fstrim.enable = true;

  persistence = {
    "/nix/persist/root" = {
      bluetooth.enable = true;
      ssh = {
        enable = true;
        hostKeys = [
          "ssh_host_ed25519_key"
          "ssh_host_rsa_key"
        ];
      };
      users.reid = {
        ssh = {
          enable = true;
          keys = [ "id_ed25519" ];
        };
      };
    };
  };

  time.timeZone = "Asia/Shanghai";

  services.displayManager.sddm.settings = {
    Users.HideUsers = "test";
  };

  home-manager.users = {
    reid =
      {
        pkgs,
        home,
        user,
        suites,
        ...
      }:
      {
        imports = [
          user.reid.home.default
          suites.develop.home
        ];

        home.stateVersion = "24.11";
      };
  };

  system.stateVersion = "24.11";
}

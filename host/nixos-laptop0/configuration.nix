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
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./filesystem.nix

    suites.develop.system

    parts.bluetooth.system.default
  ];

  boot.loader = {
    systemd-boot.enable = true;
  };

  networking = {
    hostName = "nixos-laptop0";
    networkmanager.enable = true;
  };

  services.fstrim.enable = true;

  persistence = {
    root = {
      directories = [
        "/etc/NetworkManager/system-connections"
      ];
      bluetooth.enable = true;
      ssh = {
        enable = true;
        hostKeys = [
          "ssh_host_ed25519_key"
          "ssh_host_rsa_key"
        ];
      };

      users = {
        reid = {
          ssh = {
            enable = true;
            keys = [ "id_ed25519" ];
          };
          taskwarrior.enable = true;
        };
      };
    };
  };

  users.users = {
    reid = {
      extraGroups = [
        "networkmanager"
        "wireshark"
      ];
    };
  };

  time.timeZone = "Asia/Shanghai";

  services.displayManager.sddm.settings = {
    Users.HideUsers = "test";
  };

  programs.wireshark.enable = true;

  home-manager.users = {
    reid =
      {
        pkgs,
        home,
        user,
        ...
      }:
      {
        imports = [
          user.reid.home.default
          ./home.nix
        ];

        home.stateVersion = "23.11";
      };
    test =
      { ... }:
      {
        home.stateVersion = "23.11";
      };
  };

  system.stateVersion = "23.11";
}

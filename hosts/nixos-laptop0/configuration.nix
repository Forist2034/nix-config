{
  pkgs,
  system,
  graphical,
  modules,
  home,
  inputs,
  users,
  info,
  parts,
  private,
  suites,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./filesystem.nix
    ./networking.nix

    suites.develop.system

    private.hosts.nixos-laptop0.configuration

    parts.bluetooth.system.default
    parts.taskwarrior.system.default

    system.dict

    system.mobile-sync.android
  ];

  boot.loader = {
    systemd-boot.enable = true;
  };

  boot.kernel.sysctl."kernel.sysrq" = 1;

  networking = {
    hostName = "nixos-laptop0";
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

  hardware.rtl-sdr.enable = true;

  users.users = {
    reid = {
      extraGroups = [
        "networkmanager"
        "wireshark"
        "plugdev"
        "adbusers"
      ];
    };
  };

  time.timeZone = "Asia/Shanghai";

  programs.wireshark = {
    enable = true;
    usbmon.enable = true;
    package = pkgs.wireshark;
  };

  environment.systemPackages = with pkgs; [
    nbd
    glances

    minicom

    scrcpy

    sox
  ];

  home-manager.users = {
    reid =
      {
        pkgs,
        home,
        users,
        ...
      }:
      {
        imports = [
          users.reid.home.default
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

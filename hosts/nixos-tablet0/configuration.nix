{
  pkgs,
  info,
  parts,
  private,
  suites,
  lib,
  system,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./filesystem.nix
    ./networking.nix

    suites.develop.system

    private.hosts.nixos-tablet0.configuration

    parts.bluetooth.system.default

    system.dict
  ];

  boot.loader = {
    systemd-boot.enable = true;
  };

  networking = {
    hostName = "nixos-tablet0";
    networkmanager.enable = true;
  };

  services.fstrim.enable = true;

  persistence = {
    root = {
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
        };
      };
    };
  };

  time.timeZone = "Asia/Shanghai";

  environment.systemPackages = with pkgs; [
    maliit-framework
    maliit-keyboard

    vlc
  ];

  home-manager.users = {
    reid =
      { users, ... }:
      {
        imports = [
          users.reid.home.default
          ./home.nix
        ];

        home.stateVersion = "25.05";
      };
    test =
      { lib, ... }:
      {
        home.stateVersion = lib.trivial.release;
      };
  };

  system.stateVersion = "25.05";
}

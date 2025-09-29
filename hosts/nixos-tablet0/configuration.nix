{
  pkgs,
  info,
  parts,
  private,
  suites,
  lib,
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
    hostName = "nixos-tablet0";
networkmanager.enable = true;  
};

  services.fstrim.enable = true;

hardware.enableRedistributableFirmware = true;

  persistence = {
    root = {
      bluetooth.enable = true;
    };
    share-main = {
      users.reid = lib.mkForce {};
    };
  };

  time.timeZone = "Asia/Shanghai";

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
    test = {lib,...}: {
      home.stateVersion = lib.trivial.release;
    };
  };

  system.stateVersion = "25.05";
}

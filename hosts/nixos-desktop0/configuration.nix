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
  services,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    suites.develop.system

    private.hosts.nixos-desktop0.configuration

    parts.bluetooth.system.default
    parts.taskwarrior.system.default

    ./networking.nix
    ./filesystem.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
  };

  boot.kernel.sysctl."kernel.sysrq" = 1;

  networking = {
    hostName = "nixos-desktop0";
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
          taskwarrior.enable = true;
        };
      };
    };
  };

  time.timeZone = "Asia/Shanghai";

  services.displayManager.sddm.settings = {
    Users.HideUsers = "test";
  };

  specialisation = {
    remote.configuration =
      { ... }:
      {
        systemd.sleep.extraConfig = ''
          AllowSuspend=no
          AllowHibernation=no
          AllowHybridSleep=no
          AllowSuspendThenHibernate=no
        '';

      };
  };
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

        home.stateVersion = "24.11";
      };
    test =
      { ... }:
      {
        home.stateVersion = "24.11";
      };
  };

  system.stateVersion = "24.11";
}

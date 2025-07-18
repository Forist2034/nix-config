{
  inputs,
  pkgs,
  lib,
  modulesPath,
  parts,
  services,
  users,
  info,
  # legacy args
  system,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    ./hardware-configuration.nix
    ./filesystem.nix
    ./networking.nix

    inputs.impermanence.nixosModules.impermanence

    system.modules.persistence

    parts.htop.system.default

    services.openssh.system.default

    users.reid.system.profiles.base
  ];

  boot.loader = {
    # FIXME: bootloader entry installation doesn't work
    systemd-boot.enable = true;
  };
  environment.etc.uboot = {
    source = pkgs.buildUBoot {
      defconfig = "orangepi_lite_defconfig";
      extraMeta.platforms = [ info.system ];
      filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
    };
  };

  # TODO: fix driver for rtl8189
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  networking.hostName = "nixos-sbc0";

  persistence = {
    # mutable state
    state = {
      directories = [
        "/var/lib/systemd"
        "/var/log"
      ];
    };
    # immutable configurations
    config = {
      directories = [
        "/var/lib/iwd"
      ];
      files = [
        "/etc/machine-id"
      ];
      ssh = {
        enable = true;
        hostKeys = [
          "ssh_host_ed25519_key"
          "ssh_host_rsa_key"
        ];
      };
    };
  };

  users = {
    users = {
      root = {
        openssh.authorizedKeys.keyFiles = [
          ./deploy_desktop0.pub
        ];
      };
      reid = {
        hashedPasswordFile = info.userPasswordFile "reid";
      };
    };
  };
  security.sudo = {
    wheelNeedsPassword = false;
  };

  time.timeZone = "Asia/Shanghai";

  fonts.fontconfig.enable = false;
  security.pam.services.su.forwardXAuth = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    coreutils
  ];

  nixpkgs.overlays = [
    (final: prev: {
      dbus = prev.dbus.override {
        x11Support = false;
      };
    })
    (final: prev: {
      systemd = prev.systemd.override {
        withAudit = false;
        withFido2 = false;
        withPasswordQuality = false;
        withQrencode = false;
        withTpm2Tss = false;
      };
    })
  ];
  nixpkgs.flake = {
    setFlakeRegistry = false;
    setNixPath = false;
  };

  system.disableInstallerTools = true;
  image.modules.install =
    { ... }:
    {
      system.tools.nixos-generate-config.enable = true;
    };

  nix = {
    channel.enable = false;
    settings = {
      auto-optimise-store = true;
      max-jobs = 0; # disable local build
    };
  };

  system.stateVersion = "25.05";
}

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
  system.build.uboot = pkgs.buildUBoot {
    defconfig = "orangepi_lite_defconfig";
    extraMeta.platforms = [ info.system ];
    filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
  };

  # TODO: fix driver for rtl8189
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  boot.kernelParams = [
    "panic=1"
    "boot.panic_on_fail"
    "nomodeset"
  ];
  systemd.enableEmergencyMode = false;
  systemd.watchdog = {
    runtimeTime = "15s";
    rebootTime = "15s";
  };

  systemd.services.set-sys-led = {
    after = [ "basic.target" ];
    requires = [ "basic.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      echo 1 > '/sys/class/leds/orangepi:red:sys/brightness'
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

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
      users.reid = {
        files = [
          ".android/adbkey"
          ".android/adbkey.pub"
        ];
      };
    };
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        openssh.authorizedKeys.keyFiles = [
          ./deploy_desktop0.pub
        ];
      };
      reid = {
        hashedPasswordFile = info.userPasswordFile "reid";
        extraGroups = [
          "adbusers"
          "audio"
        ];
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

    sox # audio tools
    iperf3 # for network performance testing
  ];

  hardware.alsa = {
    enable = true;
  };

  programs.adb = {
    enable = true;
  };

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
        withTpm2Tss = false;
      };
    })
    (final: prev: {
      # networkd-dispatcher transitively depends on it
      cairo = prev.cairo.override {
        x11Support = false;
      };
    })
    # TODO: use upstream package when fixed
    (final: prev: {
      networkd-dispatcher = prev.networkd-dispatcher.overrideAttrs (
        finalAttrs: prevAttrs: {
          nativeBuildInputs = with pkgs; [
            asciidoc # for a2x
            installShellFiles
            wrapGAppsNoGuiHook
          ];
          buildInputs = with pkgs; [
            python3Packages.wrapPython
            python3Packages.pygobject3
          ];
        }
      );
    })
    (final: prev: {
      ffmpeg = prev.ffmpeg-headless.override {
        withAmf = false;
        withAom = false;
        withAss = false;
        withBluray = false;
        withCudaLLVM = false;
        withCuvid = false;
        withDav1d = false;
        withDrm = false;
        withFontconfig = false;
        withFreetype = false;
        withFribidi = false;
        withGnutls = false;
        withHarfbuzz = false;
        withOpencl = false;
        withOpenjpeg = false;
        withOpenmpt = false;
        withRist = false;
        withSrt = false;
        withSoxr = false;
        withSpeex = false;
        withSvtav1 = false;
        withTheora = false;
        withV4l2 = false;
        withVaapi = false;
        withVidStab = false;
        withVorbis = false;
        withVpx = false;
        withVulkan = false;
        withWebp = false;
        withX264 = false;
        withX265 = false;
        withXvid = false;
        withZimg = false;
        withZvbi = false;
      };
    })
    (final: prev: {
      alsa-utils = prev.alsa-utils.override {
        withPipewireLib = false;
      };
    })
  ];
  nixpkgs.flake = {
    setFlakeRegistry = false;
    setNixPath = false;
  };

  system.disableInstallerTools = true;
  nix = {
    channel.enable = false;
    settings = {
      auto-optimise-store = true;
      max-jobs = 0; # disable local build
    };
  };

  image.modules = {
    install =
      { ... }:
      {
        system.tools.nixos-generate-config.enable = true;
      };
    ro-image =
      { ... }:
      {
        nix.enable = false;
        system = {
          switch.enable = false;
        };
      };
  };

  system.stateVersion = "25.05";
}

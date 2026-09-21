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

    # some parts of memory have failed, find and disable them
    "memtest=32"
  ];
  systemd.enableEmergencyMode = false;
  systemd.settings.Manager = {
    RuntimeWatchdogSec = "15s";
    RebootWatchdogSec = "15s";
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
  services.lvm.enable = false;

  environment.defaultPackages = [ ];
  environment.systemPackages = with pkgs; [
    coreutils
    android-tools

    iperf3 # for network performance testing

    # audio tools
    opus-tools
    flac

    # experimental network voice transport
    srt
  ];

  hardware.alsa = {
    enable = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      dbus = prev.dbus.override {
        x11Support = false;
      };
    })
    (final: prev: {
      systemd =
        if final.stdenv.hostPlatform != final.stdenv.buildPlatform then
          prev.systemd.override {
            withAcl = true;
            withAnalyze = false;
            withApparmor = false;
            withAudit = false;
            withCompression = true;
            withCoredump = true;
            withCryptsetup = false;
            withRepart = false;
            withDocumentation = false;
            withEfi = true;
            withFido2 = false;
            withGcrypt = false;
            withHostnamed = false;
            withHomed = false;
            withHwdb = true;
            withImportd = false;
            withLibBPF = false;
            withLibidn2 = false;
            withLocaled = false;
            withLogind = true;
            withMachined = false;
            withNetworkd = true;
            withNss = true;
            withOomd = true;
            withOpenSSL = false;
            withPCRE2 = true;
            withPam = true;
            withPolkit = false;
            withPortabled = false;
            withRemote = false;
            withResolved = true;
            withShellCompletions = true;
            withSysupdate = false;
            withSysusers = true;
            withTimedated = true;
            withTimesyncd = true;
            withTpm2Tss = false;
            withUserDb = false;
            withUkify = false;
            withBootloader = true;
            withPasswordQuality = false;
            withVmspawn = false;
            withQrencode = true;
            withLibarchive = false;
            withVConsole = true;
            # withKmod = false; # breaks udevCheckHook of bcache-tools
            withFirstboot = false;
            withKexectools = false;
            withLibseccomp = false;
            withNspawn = true;
          }
        else
          prev.systemd;
    })
    (final: prev: {
      # networkd-dispatcher transitively depends on it
      gobject-introspection = prev.gobject-introspection.override {
        x11Support = false;
        cairo = null;
        gnome = null;
      };
      python3 = prev.python3.override {
        packageOverrides = py-final: py-prev: {
          pygobject3 =
            (py-prev.pygobject3.override {
              pycairo = null;
              cairo = null;
              gnome = null;
            }).overrideAttrs
              {
                mesonFlags = [ "-Dpycairo=disabled" ];
              };
        };
      };
    })
    (final: prev: {
      # FIXME: use upstream package when fixed
      opus-tools = prev.opus-tools.overrideAttrs (
        finalAttrs: prevAttrs: {
          # fatal error: 'opus.h' file not found
          env.NIX_CFLAGS_COMPILE = "-I${final.libopus.dev}/include/opus -I${final.libopusenc.dev}/include/opus -I${final.opusfile.dev}/include/opus";
        }
      );
    })
    (final: prev: {
      alsa-utils = prev.alsa-utils.override {
        withPipewireLib = false;
      };
      alsa-plugins = prev.alsa-plugins.override {
        ffmpeg = null;
        libjack2 = null;
        libpulseaudio = null;
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

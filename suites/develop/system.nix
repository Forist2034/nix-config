{
  inputs,
  pkgs,
  lib,
  hosts,
  parts,
  services,
  suites,
  users,
  # legacy modules
  graphical,
  system,
  modules,
  home,
  info,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence

    system.nix
    system.tools.base
    system.tools.admin
    system.modules.persistence

    graphical.fonts.default
    graphical.plasma

    users.reid.system.default
    users.test.system.default

    modules.develop.system
    system.modules.tools

    parts.ssh.system.default
    parts.firefox.system.default
    system.modules.thunderbird

    parts.github.system.default

    system.smart

    services.openssh.system.default
  ];

  persistence = {
    root = {
      persistStorageRoot = "/nix/persist/root";
      directories = [
        "/etc/nixos"
        "/var/lib/systemd/catalog"
        "/var/lib/systemd/timers"
        "/var/log"
      ];
      files = [ "/etc/machine-id" ];

      users.reid = {
        directories = [
          "Documents"
          "Source"
        ];
        gpg.enable = true;
        gopass.enable = true;

        firefox = {
          enable = true;
          profiles.default = {
            enable = true;
            account.enable = true;
            bookmarkbackups.enable = true;
          };
        };
        thunderbird = {
          enable = true;
          profiles.default.enable = true;
        };

        gh.enable = true;
      };
    };
    share-main = {
      persistStorageRoot = "/nix/persist/share-main";
      share = {
        enable = true;
      };
      users.reid = {
        firefox = {
          enable = true;
          profiles.default = {
            enable = true;
            bookmarks.enable = true;
          };
        };
      };
    };
  };

  users = {
    mutableUsers = false;
    groups = {
      share-main.gid = 2001;
    };
    users.reid = {
      hashedPasswordFile = "/nix/secrets/passwords/reid";
      extraGroups = [ "share-main" ];
    };
  };

  services.xserver.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  environment.systemPackages = with pkgs; [
    dnsutils
    usbutils

    man-pages
    man-pages-posix

    jq
  ];

  documentation = {
    dev.enable = true;
  };

  programs.ssh = {
    extraConfig = lib.mkMerge [
      hosts.nixos-desktop0.sshConfig
      hosts.nixos-laptop0.sshConfig
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit
        inputs
        parts
        suites
        users
        ;
      inherit info home modules;
    };
    sharedModules = [
      (
        { home, ... }:
        {
          imports = [
            home.kde.default
            parts.firefox.home.default
            home.starship
          ];

          programs.bash.enable = true;
        }
      )
    ];
    users.test = { ... }: { };
  };

  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    flake-registry = "";
    keep-outputs = true;
  };
}

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
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    system.nix
    system.tools.min
    system.tools.base
    system.tools.admin
    system.modules.persistence

    graphical.fonts.dev
    graphical.plasma

    user.reid.system.default
    user.test.system.default

    parts.bluetooth.system.default

    modules.develop.system
    system.modules.tools
    parts.ssh.system.default
    parts.github.system.default
    parts.firefox.system.default
    system.modules.thunderbird

    system.smart
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
      directories = [
        "/etc/nixos"
        "/var/lib/systemd/catalog"
        "/var/lib/systemd/timers"
        "/var/log"
      ];
      files = [ "/etc/machine-id" ];
      bluetooth.enable = true;
      users = {
        reid = {
          directories = [
            "Documents"
            "Source"
          ];
          firefox = {
            enable = true;
            profiles.default = {
              enable = true;
              account.enable = true;
            };
          };
          thunderbird = {
            enable = true;
            profiles.default.enable = true;
          };
          gpg.enable = true;
          ssh = {
            enable = true;
            keys = [ "id_ed25519" ];
          };
          gopass.enable = true;
          gh.enable = true;
        };
      };
    };
    "/nix/persist/share-main" = {
      users = {
        reid = {
          directories = [
            "Shared/main"
          ];
        };
      };
    };
  };

  users = {
    mutableUsers = false;
    groups = {
      share-main.gid = 2001;
    };
    users =
      let
        passFile = name: "/nix/secrets/passwords/${name}";
      in
      {
        reid = {
          hashedPasswordFile = passFile "reid";
          extraGroups = [ "share-main" ];
        };
      };
  };

  services.xserver.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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

  time.timeZone = "Asia/Shanghai";

  services.displayManager.sddm.settings = {
    Users.HideUsers = "test";
  };

  environment.systemPackages = with pkgs; [
    dnsutils
    usbutils

    man-pages
    man-pages-posix
  ];

  documentation = {
    dev.enable = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit
        home
        user
        info
        modules
        parts
        ;
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
    users = {
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

          home.stateVersion = "24.11";
        };
    };
  };

  system.stateVersion = "24.11";

  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    flake-registry = "";
    keep-outputs = true;
  };
}

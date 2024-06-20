{
  pkgs,
  system,
  graphical,
  modules,
  home,
  inputs,
  user,
  info,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./filesystem.nix
    system.nix
    system.tools.min
    system.tools.base
    system.tools.admin
    system.modules.persistence

    graphical.fonts.dev
    graphical.plasma

    user.reid.base
    user.test.base

    modules.develop.system
    system.modules.firefox
    system.modules.thunderbird
    system.modules.tools

    ./local_cdn.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
  };

  networking = {
    hostName = "nixos-laptop0";
    networkmanager.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services.fstrim.enable = true;

  persistence."/nix/persist" = {
    directories = [
      "/etc/nixos"
      "/var/lib/systemd/catalog"
      "/var/lib/systemd/timers"
      "/var/log"
      "/etc/NetworkManager/system-connections"
      "/var/cache/local_cdn/proxy"
    ];
    files = [ "/etc/machine-id" ];
    users = {
      reid = {
        directories = [
          "Documents"
          "Source"
          "Shared/main"
        ];
        firefox = {
          enable = true;
          profiles.default.enable = true;
        };
        thunderbird = {
          enable = true;
          profiles.default.enable = true;
        };
        gpg.enable = true;
        ssh.enable = true;
        gopass.enable = true;
        gh.enable = true;
      };
    };
  };

  users = {
    mutableUsers = false;
    groups = {
      share-main.gid = 2001;
      share-test.gid = 2002;
    };
    users =
      let
        passFile = name: "/nix/secrets/passwords/${name}";
      in
      {
        reid = {
          hashedPasswordFile = passFile "reid";
          extraGroups = [
            "networkmanager"
            "share-main"
          ];
        };
      };
  };

  services.xserver.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
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

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit
        home
        user
        info
        modules
        ;
    };
    sharedModules = [
      (
        { home, ... }:
        {
          imports = [
            home.kde.default
            home.kde.bluedevil
            home.firefox.default
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
            user.reid.git
            user.reid.email
            ./home.nix
          ];

          accounts.email.accounts = {
            outlook = {
              thunderbird.enable = true;
            };
          };

          programs.git = {
            signing.signByDefault = true;
          };

          home.stateVersion = "23.11";
        };
      test =
        { ... }:
        {
          home.stateVersion = "23.11";
        };
    };
  };

  system.stateVersion = "23.11";

  nix.settings = {
    substituters = [ "https://mirrors.bfsu.edu.cn/nix-channels/store" ];
    flake-registry = "";
    keep-outputs = true;
  };
}

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
    system.modules.tools
  ];

  boot.loader = {
    systemd-boot.enable = true;
  };

  networking = {
    hostName = "nixos-desktop0";
    networkmanager.enable = true;
  };

  services.fstrim.enable = true;

  persistence."/nix/persist" = {
    directories = [
      "/etc/nixos"
      "/var/lib/systemd/catalog"
      "/var/lib/systemd/timers"
      "/var/log"
    ];
    files = [ "/etc/machine-id" ];
    users = {
      reid = {
        directories = [
          "Documents"
          "Source"
        ];
        firefox = {
          enable = true;
          profiles.default.enable = true;
        };
        gpg.enable = true;
      };
    };
  };

  users = {
    mutableUsers = false;
    users =
      let
        passFile = name: "/nix/secrets/passwords/${name}";
      in
      {
        reid = {
          hashedPasswordFile = passFile "reid";
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
          ];

          programs.git = {
            signing.signByDefault = true;
          };

          home.stateVersion = "24.11";
        };
    };
  };

  system.stateVersion = "24.11";

  nix.settings = {
    substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
    flake-registry = "";
    keep-outputs = true;
  };
}

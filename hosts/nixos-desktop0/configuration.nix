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

    inputs.microvm.nixosModules.host

    private.hosts.nixos-desktop0.configuration

    parts.bluetooth.system.default
    parts.taskwarrior.system.default
    parts.openrgb.system.default

    parts.libvirt.system.default

    ./networking.nix
    ./filesystem.nix

    system.mobile-sync.android
    system.mobile-sync.ios

    system.dict

    ./containers.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
  };

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv7l-linux"
  ];

  boot.kernel.sysctl."kernel.sysrq" = 1;

  networking = {
    hostName = "nixos-desktop0";
    hosts."127.0.0.1" = [
      "ajax.googleapis.com"
      "fonts.googleapis.com"
      "googletagmanager.com"
      "www.googletagmanager.com"
    ];
  };

  services.fstrim.enable = true;

  users.users = {
    reid.extraGroups = [
      "adbusers"
      "wireshark"
      "plugdev"
      "ftdi"
    ];
    # admin = {
    #   uid = 2048;
    #   isNormalUser = true;
    #   extraGroups = [ "wheel" ];
    # };
  };
  users.groups.plugdev = { };

  persistence = {
    root = {
      libvirt.enable = true;
      openrgb.enable = true;
      bluetooth.enable = true;
      ssh = {
        enable = true;
        hostKeys = [
          "ssh_host_ed25519_key"
          "ssh_host_rsa_key"
        ];
      };
      users = {
        # admin = {
        #   gpg.enable = true;

        #   directories = [
        #     "Source"
        #     "Documents"
        #   ];
        # };

        reid = {
          ssh = {
            enable = true;
            keys = [ "id_ed25519" ];
          };
          haskell = {
            cabal = {
              enable = true;
              store.enable = true;
              config.enable = true;
            };
          };

          taskwarrior.enable = true;
        };
      };
    };
    share-main.users = {
      reid = {
        haskell = {
          cabal = {
            enable = true;
            packages.enable = true;
          };
        };
        rust.enable = true;
        coursier.enable = true;
        java = {
          maven.enable = true;
          gradle.enable = true;
        };
      };
    };
  };

  time.timeZone = "Asia/Shanghai";

  services.displayManager.sddm.settings = {
    Users.HideUsers = "test";
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
    nix-serve
    nbd

    minicom
    erofs-utils

    glances

    scrcpy
    sox

    beep

  ];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="PC Speaker", ENV{DEVNAME}!="", TAG+="uaccess"

    ACTION!="add|change", GOTO="usb_rule_end"
    SUBSYSTEM!="usb|tty|hidraw", GOTO="usb_rule_end"
    ${builtins.concatStringsSep "\n" (
      builtins.map
        (
          v:
          builtins.concatStringsSep "\n" (
            builtins.map (pid: ''
              ATTRS{idVendor}=="${v.vid}", ATTRS{idProduct}=="${pid}", MODE="660", GROUP="plugdev", TAG+="uaccess"
            '') v.pid
          )
        )
        [
          # stm32 dfu
          {
            vid = "0483";
            pid = [ "df11" ];
          }
          {
            vid = "1a86";
            pid = [
              "55de" # ch347F
              # ch340
              "7523"
              "7584"
              # ch341
              "5523"
              "5584"
              "5512"
            ];
          }
          {
            vid = "0403";
            pid = [
              "6010" # ft2232
            ];
          }
          {
            vid = "067b";
            pid = [
              "2303" # pl2303
            ];
          }
          # rp2350
          {
            vid = "2e8a";
            pid = [ "000f" ];
          }
        ]
    )}
    LABEL="usb_rule_end"
  '';
  hardware.libftdi.enable = true;

  programs.wireshark = {
    enable = true;
    usbmon.enable = true;
    package = pkgs.wireshark;
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
    # admin =
    #   { modules, ... }:
    #   {
    #     imports = [
    #       modules.develop.home

    #       inputs.nixvim.homeManagerModules.nixvim
    #       home.nixvim.full
    #     ];

    #     develop.nix = {
    #       enable = true;
    #       editor = {
    #         nixvim.enable = true;
    #       };
    #       browser.firefox = {
    #         enable = true;
    #         profiles.default.enable = true;
    #       };
    #     };

    #     programs.nixvim = {
    #       autoCmd = [
    #         {
    #           event = [ "VimLeave" ];
    #           pattern = [ "*" ];
    #           command = "set guicursor=a:ver25";
    #         }
    #       ];
    #     };

    #     home.stateVersion = "25.05";
    #   };
    reid =
      {
        config,
        pkgs,
        home,
        users,
        ...
      }:
      {
        imports = [
          users.reid.home.default
          ./home.nix

          (import ./http-capture.nix {
            profile_id = 2;
            port = 2048;
          })
        ];

        programs.taskwarrior.config = {
          uda = {
            doi = {
              type = "string";
              label = "doi";
            };
          };
        };

        programs.git = {
          extraConfig = {
            safe.directory = [
              "~/Shared/share-main/*"
            ];
          };
        };
        home.stateVersion = "24.11";
      };
    test =
      { ... }:
      {
        home.stateVersion = "24.11";
      };
  };

  # temporary keep packages
  system.extraDependencies = (
    with pkgs;
    [
      kicad

      openscad
      openscad-unstable
      freecad

      openocd
      gcc-arm-embedded

      wayland-proxy-virtwl
      waypipe

      jadx

      libreoffice-qt6-fresh

      qt6Packages.fcitx5-with-addons
      fcitx5-rime
      rime-data
      rime-zhwiki

      rustup
    ]
  );
  # ++ (with pkgs.maple-mono; [
  #   opentype
  #   CN
  #   CN-unhinted
  #   NF-CN
  #   NF-CN-unhinted
  #   NL-OTF
  #   NL-CN
  #   NL-CN-unhinted
  #   NL-NF-CN
  #   NL-NF-CN-unhinted
  #   Normal-OTF
  #   Normal-CN
  #   Normal-CN-unhinted
  #   Normal-NF-CN
  #   Normal-NF-CN-unhinted
  #   NormalNL-OTF
  #   NormalNL-CN
  #   NormalNL-CN-unhinted
  #   NormalNL-NF-CN
  #   NormalNL-NF-CN-unhinted
  # ]);

  system.stateVersion = "24.11";
}

{
  users,
  private,
  services,
  info,
  local-lib,
  ...
}:
{
  imports = [
    (local-lib.containers.gui-container {
      name = "stm32-dev";
      gpu = true;
      home = true;
      config = {
        system = name: {
        };
        container = name: {
          privateNetwork = true;
          bindMounts = {
            usbBus = {
              hostPath = "/dev/bus/usb";
              mountPoint = "/dev/bus/usb";
              isReadOnly = true;
            };
          };
          allowedDevices = [
            {
              # stm32 usb dfu mode
              node = "char-usb_device";
              modifier = "rw";
            }
          ];
          config =
            { pkgs, ... }:
            let
              stm32prog-unwrapped =
                let
                  version = "2.20.0";
                  bin-env = pkgs.symlinkJoin {
                    name = "stm32cubeprog-setup-bin";
                    paths = with pkgs; [
                      bash
                      coreutils
                      gnutar
                    ];
                  };
                in
                pkgs.vmTools.runInLinuxVM (
                  pkgs.stdenvNoCC.mkDerivation {
                    pname = "stm32cubeprog-unwrapped";
                    inherit version;

                    # TODO: use direct download link
                    # src = pkgs.fetchzip {
                    #   url = "https://sw-center.st.com/packs/resource/library/stm32cubeprg-v${
                    #     builtins.replaceStrings [ "." ] [ "-" ] version
                    #   }-lin.zip";
                    #   hash = "sha256-mgT2blcS7ttnWgP0skVPuK5w/nxFDqrN2NkmVBkzg+A=";
                    #   stripRoot = false;
                    # };
                    src = pkgs.requireFile {
                      name = "stm32cubeprg-lin-v${builtins.replaceStrings [ "." ] [ "-" ] version}.zip";
                      url = "https://www.st.com/en/development-tools/stm32cubeprog.html";
                      hash = "sha256-X+Jqk1DAxyw7SoeqMBL962z7CVKz4PwFuoTwSfLxQB4=";
                    };

                    nativeBuildInputs = [
                      pkgs.unzip
                    ];

                    buildCommand = ''
                      cat << EOF > auto-install.xml
                      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
                      <AutomatedInstallation langpack="eng">
                          <com.st.CustomPanels.CheckedHelloPorgrammerPanel id="Hello.panel"/>
                          <com.izforge.izpack.panels.info.InfoPanel id="Info.panel"/>
                          <com.izforge.izpack.panels.licence.LicencePanel id="Licence.panel"/>
                          <com.st.CustomPanels.TargetProgrammerPanel id="target.panel">
                              <installpath>$out</installpath>
                          </com.st.CustomPanels.TargetProgrammerPanel>
                          <com.st.CustomPanels.AnalyticsPanel id="analytics.panel"/>
                          <com.st.CustomPanels.PacksProgrammerPanel id="Packs.panel">
                              <pack index="0" name="Core Files" selected="true"/>
                              <pack index="1" name="STM32CubeProgrammer" selected="true"/>
                              <pack index="2" name="STM32TrustedPackageCreator" selected="true"/>
                          </com.st.CustomPanels.PacksProgrammerPanel>
                          <com.izforge.izpack.panels.install.InstallPanel id="Install.panel"/>
                          <com.izforge.izpack.panels.shortcut.ShortcutPanel id="Shortcut.panel">
                              <createMenuShortcuts>true</createMenuShortcuts>
                              <programGroup>STMicroelectronics\STM32CubeProgrammer</programGroup>
                              <createDesktopShortcuts>false</createDesktopShortcuts>
                              <createStartupShortcuts>false</createStartupShortcuts>
                              <shortcutType>user</shortcutType>
                          </com.izforge.izpack.panels.shortcut.ShortcutPanel>
                          <com.st.CustomPanels.FinishProgrammerPanel id="finish.panel"/>
                      </AutomatedInstallation>
                      EOF

                      mkdir /usr
                      ln -svf ${bin-env}/bin /usr
                      rm -rf /bin
                      ln -svf ${bin-env}/bin /bin

                      unzip $src
                      ${pkgs.jdk}/bin/java -jar SetupSTM32CubeProgrammer-${version}.exe "$(pwd)/auto-install.xml"
                    '';

                    memSize = 1024;
                  }
                );

              stm32prog = pkgs.buildFHSEnv {
                name = "stm32cubeprog-env";
                targetPkgs =
                  pkgs: with pkgs; [
                    krb5.lib
                    libusb1
                    glib
                    zlib

                    gtk3
                    gdk-pixbuf
                    pango
                    cairo
                    atk
                    xorg.libX11
                    xorg.libXtst
                    xorg.libXext
                    xorg.libXrandr
                    xorg.libXi
                    alsa-lib

                    udev

                    stm32prog-unwrapped
                  ];
                profile = ''
                  unset WAYLAND_DISPLAY
                  alias STM32CubeProgrammer=/usr/bin/STM32CubeProgrammerLauncher
                '';
                runScript = "bash";
              };

              stm32cubeide-unwrapped =
                let
                  version = "1.19.0_25607_20250703_0907";
                in
                pkgs.stdenvNoCC.mkDerivation {
                  pname = "stm32cubeide-unwrapped";
                  inherit version;

                  # TODO: use direct download link
                  src = pkgs.requireFile {
                    name = "st-stm32cubeide_${version}_amd64.sh.zip";
                    url = "https://www.st.com/en/development-tools/stm32cubeide.html";
                    hash = "sha256-+jeXv7+ywRhgQAIl7aFCnRzhbVJZPlW6JICvGLacPG0=";
                  };

                  nativeBuildInputs = [ pkgs.unzip ];

                  buildCommand = ''
                    unzip $src
                    mkdir inner
                    bash ./st-stm32cubeide_${version}_amd64.sh --target ./inner --noexec
                    mkdir $out
                    tar -C $out -xf inner/st-stm32cubeide_${version}_amd64.tar.gz
                  '';
                };
              stm32cubeide = pkgs.buildFHSEnv {
                name = "stm32cubeide";
                targetPkgs =
                  pkgs: with pkgs; [
                    krb5.lib
                    libusb1
                    glib
                    zlib

                    gtk3
                    gdk-pixbuf
                    pango
                    cairo
                    atk
                    xorg.libX11
                    xorg.libXtst
                    xorg.libXext
                    xorg.libXrandr
                    xorg.libXi
                    alsa-lib

                    udev
                  ];
                runScript = "${stm32cubeide-unwrapped}/stm32cubeide";
              };
            in
            {
              imports = [
                users.reid.system.profiles.base
              ];

              environment.systemPackages = [
                pkgs.stm32cubemx
                stm32prog
                stm32cubeide
              ];

              nixpkgs.config.allowUnfree = true;
            };
        };
      };
    })

    (local-lib.containers.gui-container {
      name = "test-container";
      gpu = true;
      config = {
        system = name: { };
        container = name: {
          privateNetwork = true;
          config =
            { pkgs, ... }:
            {
              imports = [
                users.reid.system.profiles.base
                users.test.system.default
              ];
            };
        };
      };
    })
  ];

  containers = {
    # proxy-capture = {
    #   bindMounts = {
    #     unixExport = {
    #       hostPath = "/run/nixos-container/proxy-capture/unix-export";
    #       mountPoint = "/run/host/unix-export";
    #       isReadOnly = false;
    #     };
    #   };

    #   privateNetwork = true;
    #   enableTun = true;
    #   hostAddress6 = "fde0:9036:4433:10::1";
    #   localAddress6 = "fde0:9036:4433:10::2";
    #   forwardPorts = [
    #     {
    #       protocol = "tcp";
    #       hostPort = 8080;
    #     }
    #   ];

    #   config =
    #     { pkgs, lib, ... }:
    #     {
    #       imports = [
    #         services.openssh.system.profiles.default

    #         users.reid.system.profiles.base
    #       ];

    #       environment.systemPackages = [
    #         pkgs.socat
    #         pkgs.tun2socks
    #       ];

    #       networking.nameservers = [
    #         "fde0:9036:4433:20::1"
    #       ];

    #       system.stateVersion = lib.trivial.release;
    #     };
    # };
  };

  systemd.services."container@proxy-capture" = {
    serviceConfig = {
      RuntimeDirectory = [
        "nixos-container/%i/unix-export"
      ];
    };
  };

  # networking = {
  #   hosts = {
  #     "fde0:9036:4433::2" = [ "proxy-capture" ];
  #   };
  #   networkmanager.ensureProfiles = {
  #     profiles = {
  #       vm-proxy-capture = {
  #         connection = {
  #           id = "Vm-Proxy-Capture";
  #           type = "ethernet";
  #           interface-name = "vm-proxy-rec";
  #           uuid = "ca1be93b-cdd5-4ba3-86e8-09d85cc60394";
  #         };
  #         ipv4.method = "disabled";
  #         ipv6 = {
  #           method = "manual";
  #           address1 = "fde0:9036:4433::1/64";
  #         };
  #       };
  #     };
  #   };
  # };

  microvm.vms = {
    # proxy-capture = {
    #   config =
    #     { pkgs, lib, ... }:
    #     {

    #       imports = [
    #         services.openssh.system.profiles.default

    #         users.reid.system.profiles.base
    #       ];

    #       fileSystems."/" = {
    #         device = "none";
    #         fsType = "tmpfs";
    #         options = [
    #           "size=128M"
    #           "mode=755"
    #         ];
    #       };

    #       security.sudo.wheelNeedsPassword = false;

    #       services.redsocks = {
    #         enable = true;
    #         redsocks = [
    #           {
    #             type = "socks5";
    #             proxy = "[fde0:9036:4433::1]:8192";
    #           }
    #         ];
    #       };

    #       environment.systemPackages = [
    #         pkgs.mitmproxy
    #       ];

    #       microvm = {
    #         vcpu = 4;

    #         balloon = true;
    #         mem = 2 * 1024;

    #         vsock.cid = 128;
    #         interfaces = [
    #           {
    #             type = "tap";
    #             id = "vm-proxy-rec";
    #             mac = "02:00:00:00:00:7f";
    #           }
    #         ];

    #         writableStoreOverlay = "/nix/.rw-store";
    #         shares = [
    #           {
    #             proto = "9p";
    #             tag = "host-store";
    #             source = "/nix/store";
    #             mountPoint = "/nix/.ro-store";
    #           }
    #         ];
    #       };

    #       system.stateVersion = lib.trivial.release;
    #     };
    # };
  };
}

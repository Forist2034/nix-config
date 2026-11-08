{ devLib, ... }:
let
  name = "stm32";
in
{
  inherit name;

  home =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options = with lib; {
        cfglib.develop.stm32 = {
          enable = mkEnableOption "stm32 support";
          packages = {
            cubeprog = mkEnableOption "stm32cborprog";
            cubeide = mkEnableOption "stm32cubeide";
            cubemx = mkEnableOption "stm32cubemx";
          };
        };
      };
      config =
        let
          cfg = config.cfglib.develop.stm32;

          stm32cubeprog-unwrapped =
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

          stm32cubeprog = pkgs.buildFHSEnv {
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
                libX11
                libXtst
                libXext
                libXrandr
                libXi
                alsa-lib

                udev

                stm32cubeprog-unwrapped
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
                libX11
                libXtst
                libXext
                libXrandr
                libXi
                alsa-lib

                udev
              ];
            runScript = "${stm32cubeide-unwrapped}/stm32cubeide";
          };

        in
        lib.mkIf cfg.enable {
          home.packages = [
            (lib.mkIf cfg.packages.cubeprog stm32cubeprog)
            (lib.mkIf cfg.packages.cubeide stm32cubeide)
            (lib.mkIf cfg.packages.cubemx pkgs.stm32cubemx)
          ];
        };
    };
}

{ config, pkgs, ... }:
let
  dtbFilename = config.hardware.deviceTree.name;
  dtbFile = "${config.hardware.deviceTree.package}/${dtbFilename}";
in
{
  nixpkgs.hostPlatform = {
    system = "armv7l-linux";
  };

  hardware.deviceTree = {
    enable = true;
    name = "sun8i-h3-orangepi-lite.dtb";
    filter = "*orangepi-lite*.dtb";
    overlays = [
      {
        name = "power_key";
        dtsFile = ./power_key.dts;
      }
      {
        name = "leds";
        dtsFile = ./leds.dts;
      }
      {
        name = "pheripheral";
        dtsFile = ./soc_peripheral.dts;
      }
    ];
  };

  boot.kernelPackages =
    let
      baseKernel = pkgs.linuxPackages.kernel;
    in
    pkgs.linuxPackagesFor (
      pkgs.linuxManualConfig {
        inherit (baseKernel)
          version
          modDirVersion
          src
          kernelPatches
          ;
        configfile = ./kernel-config;
        features = {
          efiBootStub = true;
          netfilterRPFilter = true;
        };
      }
    );
  boot.initrd.includeDefaultModules = false;
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8189fs
  ];
  boot.kernelModules = [
    "ledtrig_netdev"
  ];

  boot.uki.settings = {
    UKI = {
      DeviceTree = dtbFile;
    };
  };

  # TODO: add device tree config for systemd-boot
}

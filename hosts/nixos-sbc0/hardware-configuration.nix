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

  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8189fs
  ];

  boot.uki.settings = {
    UKI = {
      DeviceTree = dtbFile;
    };
  };

  # TODO: add device tree config for systemd-boot
}

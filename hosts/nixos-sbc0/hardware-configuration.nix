{ config, pkgs, ... }:
{
  nixpkgs.hostPlatform = {
    system = "armv7l-linux";
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8189fs
  ];
}

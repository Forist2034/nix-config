# signal for debugging
{ pkgs, lib, ... }:
{
  hardware.deviceTree.overlays = [
    {
      name = "debug";
      dtsFile = ./debug.dts;
    }
  ];

  boot.kernelPatches = [
    {
      name = "debug";
      patch = null;
      extraStructuredConfig = {
        STRICT_DEVMEM = lib.kernel.no;
      };
    }
  ];

  systemd.services.set-sys-led = {
    script = ''
      echo 1 > '/sys/class/leds/debug:ready/brightness'
    '';
  };
}

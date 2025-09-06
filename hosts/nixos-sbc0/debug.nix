{ lib, pkgs, ... }:
{

  boot.consoleLogLevel = 7;
  boot.kernelParams = [
    "console=ttyS0,115200n8"
    "memtest=32"
  ];

  users.users.root.openssh.authorizedKeys.keyFiles = [
    ./test_deploy.pub
  ];

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

  environment.systemPackages = with pkgs; [
    memtester
    stress-ng
  ];

  systemd.services.set-sys-led = {
    script = ''
      echo 1 > '/sys/class/leds/debug:ready/brightness'
    '';
  };

  # disable ddns in debug environment
  services.update-dynv6.enable = lib.mkForce false;
  systemd.timers."update-dynv6@wlan0".enable = lib.mkForce false;
}

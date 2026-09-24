{ lib, pkgs, ... }:
{

  boot.consoleLogLevel = 7;
  boot.kernelParams = [
    "earlycon"
    "rd.systemd.debug_shell"
    "rd.systemd.default_debug_tty=ttyS0"
    "rd.systemd.log_target=console"
    "rd.systemd.log_level=debug"
    "systemd.journald.forward_to_console=1"
    "SYSTEMD_SULOGIN_FORCE=1"
  ];

  systemd.enableEmergencyMode = lib.mkForce true;
  boot.initrd.systemd.emergencyAccess = true;

  environment.systemPackages = with pkgs; [
    memtester
    stress-ng
  ];

  # disable ddns in debug environment
  services.update-dynv6.enable = lib.mkForce false;
  systemd.timers."update-dynv6@wlan0".enable = lib.mkForce false;
}

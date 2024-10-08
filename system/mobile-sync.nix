{
  ios =
    { pkgs, ... }:
    {
      services.usbmuxd.enable = true;
      environment.systemPackages = [
        pkgs.ifuse
        pkgs.libimobiledevice
      ];
    };

  android =
    { pkgs, ... }:
    {
      programs.adb.enable = true;
      environment.systemPackages = [ pkgs.android-tools ];
    };
}

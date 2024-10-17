{
  ios =
    { pkgs, ... }:
    {
      services.usbmuxd.enable = true;
      environment.systemPackages = with pkgs; [
        ifuse
        libusbmuxd # for port forwarding
        libimobiledevice
        sshfs
      ];

      programs.ssh.extraConfig = ''
        Host ios-usb
          Hostname 127.0.0.1
          StrictHostKeyChecking no
          ProxyCommand ${pkgs.libusbmuxd}/bin/inetcat 22
          UserKnownHostsFile /dev/null
      '';
    };

  android =
    { pkgs, ... }:
    {
      programs.adb.enable = true;
      environment.systemPackages = [ pkgs.android-tools ];
    };
}

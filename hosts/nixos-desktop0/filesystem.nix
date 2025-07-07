{ ... }:
{
  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/13b9d01c-1099-4f04-8453-a7982ff81141";
    allowDiscards = true;
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "size=8G"
        "mode=755"
      ];
    };

    "/nix/var/nix/builds" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "size=16G"
        "mode=755"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-partuuid/a790837d-c805-42e5-9a9a-d78aecbe0dbd";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/afbf6c2a-f84e-4112-bbc5-1733ec308105";
      fsType = "ext4";
      neededForBoot = true;
      options = [ "noatime" ];
    };
  };

  swapDevices = [ ];

  zramSwap = {
    enable = true;
  };
}

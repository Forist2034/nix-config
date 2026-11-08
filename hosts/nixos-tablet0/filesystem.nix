{ pkgs, ... }:
{
  boot.initrd.luks.devices."root" = {
    device = "/dev/disk/by-uuid/a0eae3a1-5081-460a-ad93-4531f19fce81";
    allowDiscards = true;
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "size=4G"
        "mode=755"
      ];
    };

    "/nix/var/nix/nix/builds" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "size=8G"
        "mode=755"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-partuuid/c3331ea4-5316-4aaf-8dc3-35198de924bc";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/1ec62610-9f5f-433b-ab35-9e8a72dce6c7";
      fsType = "ext4";
      neededForBoot = true;
      options = [ "noatime" ];
    };
  };

  #  swapDevices = [
  #   {
  #      device = null;
  #      randomEncryption = {
  #        enable = true;
  #        allowDiscards = true;
  #      };
  #    }
  #  ];

  #  boot.kernelParams = [
  #    "zswap.enabled=1"
  #    "zswap.max_pool_percent=48"
  #  ];

  environment.systemPackages = [ pkgs.fscrypt-experimental ];
  environment.etc."fscrypt.conf".text = builtins.toJSON {
    allow_cross_user_metadata = false;
    hash_costs = {
      memory = "131072";
      parallelism = "8";
      time = "3203";
      truncation_fixed = true;
    };
    options = {
      contents = "AES_256_XTS";
      filenames = "AES_256_CTS";
      padding = "32";
      policy_version = "2";
    };
    source = "custom_passphrase";
    use_fs_keyring_for_v1_policies = false;
  };

  zramSwap = {
    enable = true;
  };
}

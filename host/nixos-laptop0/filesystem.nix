{ pkgs, ... }: {
  boot.initrd.luks.devices."encrypted-root" = {
    device = "/dev/disk/by-uuid/52e2c5ac-ca52-4fc9-9193-4395bd422561";
    allowDiscards = true;
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-partuuid/7a4eb9bc-21c7-4a67-889c-09b230ae925f";
      fsType = "vfat";
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/ed6f3689-e429-4189-b2d3-8fb92e35100c";
      fsType = "ext4";
      neededForBoot = true;
      options = [ "noatime" ];
    };
    "/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "size=2G" "mode=755" ];
    };
  };

  swapDevices = [{
    device = "/dev/disk/by-partuuid/598db4cd-b3e0-4887-9a4f-a227b2af78c1";
    randomEncryption = {
      enable = true;
      allowDiscards = true;
    };
  }];

  # fscrypt configuration
  environment.systemPackages = [ pkgs.fscrypt-experimental ];
  environment.etc."fscrypt.conf".text = builtins.toJSON {
    source = "custom_passphrase";
    hash_costs = {
      time = "2170";
      memory = "131072";
      parallelism = "8";
    };
    options = {
      padding = "32";
      contents = "AES_256_XTS";
      filenames = "AES_256_CTS";
      policy_version = "2";
    };
    use_fs_keyring_for_v1_policies = false;
    allow_cross_user_metadata = false;
  };
}

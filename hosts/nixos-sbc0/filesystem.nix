{
  config,
  lib,
  inputs,
  ...
}:
{

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "size=128M"
        "mode=755"
      ];
    };

    "/mnt/root" = {
      neededForBoot = true;
      device = lib.mkDefault "/dev/disk/by-partlabel/sbc0-sd-root0";
      fsType = lib.mkDefault "ext4";
      options = [ "noatime" ];
    };

    "/mnt/state" = {
      neededForBoot = true;
      device = "/dev/disk/by-partlabel/sbc0-sd-state";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/mnt/config" = {
      neededForBoot = true;
      device = "/dev/disk/by-partlabel/sbc0-sd-config";
      fsType = "ext4";
      options = lib.mkDefault [ "ro" ];
    };

    "/boot" = {
      device = "/dev/disk/by-partlabel/sbc0-sd-esp";
      fsType = "vfat";
      options = [
        "noatime"
        "umask=0077"
      ];
    };

    "/nix" = {
      neededForBoot = true;
      depends = [ "/mnt/root" ];
      device = "/mnt/root/nix";
      fsType = "none";
      options = [ "bind" ];
    };
  };

  persistence = {
    state.persistStorageRoot = "/mnt/state";
    config.persistStorageRoot = "/mnt/config";
  };

  services.lvm.enable = false; # reduce image size

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  specialisation.config = {
    configuration =
      { ... }:
      {
        fileSystems = {
          "/mnt/config".options = [
            "noatime"
            "rw"
          ];
        };
      };
  };

  image.modules.install =
    {
      config,
      modulesPath,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ "${modulesPath}/image/repart.nix" ];

      fileSystems = {
        # allow write for first system configuration
        "/mnt/config".options = [
          "noatime"
          "rw"
        ];
      };

      image.repart = {
        name = "install-image";
        split = true;
        compression.enable = false;
        seed = "6dc21fbb-f6c6-4b5e-9cd6-2a36d7da683e";

        partitions = {
          esp = {
            contents =
              let
                efiArch = pkgs.stdenv.hostPlatform.efiArch;
              in
              {
                "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
                  "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

                "/EFI/Linux/install-${config.system.boot.loader.ukiFile}".source =
                  "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
              };
            repartConfig = {
              Type = "esp";
              Format = "vfat";
              Label = "sbc0-sd-esp";
              SplitName = "esp";
              SizeMinBytes = "64M";
            };
          };
          root = {
            contents = {
              "/etc/install-closure".source = pkgs.buildPackages.closureInfo {
                rootPaths = [ config.system.build.toplevel ];
              };
            };
            storePaths = [ config.system.build.toplevel ];
            repartConfig = {
              Type = "root";
              Format = "ext4";
              Label = "sbc0-sd-root0";
              SplitName = "root";
              Minimize = "guess";
            };
          };
        };
      };
    };
}

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

    "/mnt/images" = {
      device = "/dev/disk/by-partlabel/sbc0-sd-images";
      fsType = "ext4";
      options = [
        "noatime"
        "ro"
      ];
    };

    "/mnt/root" = {
      neededForBoot = true;
      device = lib.mkDefault "/dev/disk/by-label/sbc0-root";
      fsType = lib.mkDefault "ext4";
      options = lib.mkDefault [ "noatime" ];
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

  image.modules = {
    install =
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

        system = {
          nixos = {
            variant_id = "install-image";
          };
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

                  "/EFI/Linux/nixos-install-${config.system.boot.loader.ukiFile}".source =
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
                Label = "sbc0-root";
                SplitName = "root";
                Minimize = "guess";
              };
            };
          };
        };
      };
    ro-image =
      {
        inputs,
        config,
        modulesPath,
        pkgs,
        ...
      }:
      let
        efiArch = pkgs.stdenv.hostPlatform.efiArch;

        flake = inputs.self;
        commit = flake.rev or flake.dirtyRev;
        inherit (config) system;

        version = "${builtins.toString flake.lastModified}-${commit}";
        rootFileName = "nixos-sbc0-${version}.root.erofs";
        bootInfoFileName = "nixos-sbc0-${version}.boot-info.erofs";
        ukiFileName = "nixos-sbc0-${version}-${system.boot.loader.ukiFile}";
      in
      {
        imports = [ "${modulesPath}/image/repart.nix" ];

        fileSystems = {
          "/mnt/images" = {
            neededForBoot = true;
          };
          "/mnt/root" = {
            depends = [ "/mnt/images" ];
            device = "/mnt/images/${rootFileName}";
            fsType = "erofs";
          };
        };

        system = {
          image = {
            inherit version;
          };
        };

        image.repart = {
          name = "ro-image";
          split = true;
          compression.enable = false;
          seed = "5257e0f4-bcf8-4b61-8419-b64522cf4679";

          partitions = {
            boot-info = {
              contents =
                let
                in
                {
                  "/boot/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
                    "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

                  "/boot/EFI/Linux/${ukiFileName}".source = "${system.build.uki}/${system.boot.loader.ukiFile}";

                  "/filenames.json".source = builtins.toFile "filenames.json" (
                    builtins.toJSON {
                      uki = ukiFileName;
                      root = rootFileName;
                      boot-info = bootInfoFileName;
                    }
                  );
                };
              repartConfig = {
                Type = "linux-generic";
                Format = "erofs";
                Label = "boot-info";
                SplitName = "boot-info";
                Minimize = "best";
                Compression = "lz4";
              };
            };
            root = {
              storePaths = [ system.build.toplevel ];
              repartConfig = {
                Type = "root";
                Format = "erofs";
                Label = "sbc0-root-${builtins.substring 0 7 commit}";
                SplitName = "root";
                Minimize = "best";
                Compression = "lz4";
              };
            };
          };
        };
      };
  };
}

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
        "noauto"
      ];
    };

    "/nix" = {
      neededForBoot = true;
      device = lib.mkDefault "/dev/disk/by-partlabel/sbc0-sd-nix";
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

  image.modules = {
    system =
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

        environment.etc."first-boot.sh".text = ''
          #!${pkgs.bash}/bin/bash

          nix-store --load-db < /nix/install-closure/registration
          bootctl install
        '';

        image.repart = {
          name = "nixos-sbc0-install";
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

                  "/toplevel".source = pkgs.writeText "system-image-toplevel" (
                    builtins.trace "system image toplevel: ${config.system.build.toplevel}" (
                      builtins.toString config.system.build.toplevel
                    )
                  );
                };
              repartConfig = {
                Type = "esp";
                Format = "vfat";
                Label = "sbc0-sd-esp";
                SplitName = "esp";
                SizeMinBytes = "64M";
              };
            };
            nix = {
              contents = {
                "/install-closure".source = pkgs.buildPackages.closureInfo {
                  rootPaths = [ config.system.build.toplevel ];
                };
              };
              storePaths = [ config.system.build.toplevel ];
              nixStorePrefix = "/store";
              repartConfig = {
                Type = "root";
                Format = "ext4";
                Label = "sbc0-nix";
                SplitName = "nix";
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

        imageName = "nixos-sbc0-erofs";
        version = "${builtins.toString flake.lastModified}-${commit}";
        nixDataFileName = "${imageName}-${version}.nix.erofs";
        bootInfoFileName = "${imageName}-${version}.boot-info.erofs";
        ukiFileName = "${imageName}-${version}-${system.boot.loader.ukiFile}";
      in
      {
        imports = [
          "${modulesPath}/image/repart.nix"
          "${modulesPath}/profiles/perlless.nix"
        ];

        fileSystems = {
          "/nix" = {
            device = "/mnt/images/${nixDataFileName}";
            fsType = "erofs";
          };
        };

        system = {
          nixos.variant_id = "erofs-root";
          image = {
            inherit version;
          };
        };

        boot.initrd.systemd.mounts = [
          {
            what = "/dev/disk/by-partlabel/sbc0-sd-images";
            where = "/mnt/images";
            type = "ext4";
            options = "ro,noatime";

            wantedBy = [ "initrd-fs.target" ];
            before = [ "sysroot.mount" ];
          }
        ];

        image.repart = {
          name = imageName;
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
                      nix_data = nixDataFileName;
                      boot-info = bootInfoFileName;
                    }
                  );

                  "/toplevel".source = pkgs.writeText "ro-image-toplevel" (
                    builtins.trace "ro image toplevel: ${config.system.build.toplevel}" (
                      builtins.toString config.system.build.toplevel
                    )
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
            nix = {
              storePaths = [ system.build.toplevel ];
              nixStorePrefix = "/store";
              repartConfig = {
                Type = "root";
                Format = "erofs";
                Label = "sbc0-nix-${builtins.substring 0 7 commit}";
                SplitName = "nix";
                Minimize = "best";
                Compression = "lz4";
              };
            };
          };
        };
      };
  };
}

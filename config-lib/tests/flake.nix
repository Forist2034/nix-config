{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cfglib = {
      url = "path:..";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        microvm.follows = "microvm";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      impermanence,
      microvm,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        test-vm-x64_64 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            microvm.nixosModules.microvm
            home-manager.nixosModules.home-manager
            {
              microvm = {
                vcpu = 4;
                hotplugMem = 2 * 1024;
                shares = [
                  {
                    tag = "nix-store";
                    source = "/nix/store";
                    mountPoint = "/nix/.ro-store";
                    readOnly = true;
                  }
                ];
                volumes = [
                  {
                    mountPoint = "/nix/persist";
                    image = "persist.qcow";
                    fsType = "ext4";
                    autoCreate = true;
                    imageType = "qcow2";
                    label = "persist";
                    size = 128;
                  }
                ];

                vsock = {
                  cid = 1303;
                  ssh.enable = true;
                };

                # fix home-manager activation
                writableStoreOverlay = "/nix/.rw-store";

                qemu.machine = "q35"; # use virtio-mem
              };
            }
            ({ lib, ... }: {
              users.users.test = {
                isNormalUser = true;
                password = "";
                extraGroups = [ "wheel" ];
              };
              security.sudo.wheelNeedsPassword = false;
              services.getty.autologinUser = "test";

              home-manager.sharedModules = [
                ({ lib, ... }: {
                  home.stateVersion = lib.trivial.release;
                })
              ];

              system.stateVersion = lib.trivial.release;
            })
            (
              { lib, config, ... }:
              let
                cfglib = inputs.cfglib.cfglib;
                sysConfig = config;
              in
              {
                home-manager.users.test = lib.mkMerge [
                  {
                    imports = [ cfglib.develop.home ];
                    cfglib.develop = {
                      nickel.enable = true;
                    };
                  }
                  {
                    imports = [ cfglib.programs.firefox.home.default ];

                    cfglib.programs.firefox = { ... }: {
                      imports = [ cfglib.develop.submodules.firefox.global ];
                      cfglib.develop = {
                        nix = {
                          enable = true;
                          manuals = {
                            nix.package = sysConfig.nix.package;
                          };
                        };
                      };
                    };
                  }
                  {
                    imports = [ cfglib.programs.helix.home.default ];
                    cfglib.programs.helix = { ... }: {
                      imports = [ cfglib.develop.submodules.helix ];
                      cfglib.develop = {
                        nickel.enable = true;
                        nix.enable = true;
                      };
                    };
                  }
                  {
                    imports = [ cfglib.programs.nixvim.home.default ];
                    programs.nixvim.imports = [
                      {
                        imports = [ cfglib.develop.nixvim ];

                        cfglib.develop = {
                          nickel.enable = true;
                          nix.enable = true;
                        };
                      }
                    ];
                  }
                  {
                    imports = [ cfglib.programs.vscodium.home.default ];
                    programs.vscodium.profiles.default = { ... }: {
                      imports = [ cfglib.develop.submodules.vscodium ];

                      cfglib.develop = {
                        nickel.enable = true;
                        nix.enable = true;
                      };
                    };
                  }
                ];
              }
            )
          ];
        };
      };
      packages = {
        x86_64-linux = {
          test-vm = self.nixosConfigurations.test-vm-x64_64.config.microvm.declaredRunner;
        };
      };
    };
}

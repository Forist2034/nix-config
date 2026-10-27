{
  local-lib,
  devLib,
  inputs,
  ...
}:
let
  name = "nix";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Nix";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];
        userSettings = {
          "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
        };
      }
    );

    helix = mkEnableModule (
      { pkgs, ... }: {
        languages = {
          language = [
            {
              name = "nix";
              auto-format = true;
              formatter = {
                command = "${pkgs.nixfmt}/bin/nixfmt";
              };
            }
          ];
        };

      }
    );

    firefox = {
      global =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          options = {
            cfglib.develop.nix = {
              enable = lib.mkEnableOption "Nix support";
              manuals = {
                nix = {
                  enable = local-lib.options.mkDisableOption "Nix document";
                  package = lib.mkPackageOption pkgs "nix" { };
                };
                nixpkgs.enable = local-lib.options.mkDisableOption "Nixpkgs manual";
                nixos.enable = local-lib.options.mkDisableOption "Nixos manual";
                home-manager.enable = local-lib.options.mkDisableOption "Home Manager doc";
                nixvim.enable = local-lib.options.mkDisableOption "Nixvim doc";
                microvm.enable = local-lib.options.mkDisableOption "Microvm.nix doc";
              };
              search.enable = local-lib.options.mkDisableOption "Nix search engines";
            };
          };
          config =
            let
              cfg = config.cfglib.develop.nix;
              buildSys = pkgs.stdenv.buildPlatform.system;
            in
            lib.mkIf cfg.enable {
              policies = {
                ManagedBookmarks = [
                  {
                    name = "Nix Manuals";
                    children = lib.mkMerge [
                      (lib.mkIf cfg.manuals.nix.enable [
                        {
                          name = "Nix Reference Manual";
                          url = "file://${cfg.manuals.nix.package.doc}/share/doc/nix/manual/index.html";
                        }
                      ])
                      (lib.mkIf cfg.manuals.nixpkgs.enable [
                        {
                          name = "Nixpkgs manual";
                          url =
                            let
                              manual = inputs.nixpkgs.htmlDocs.nixpkgsManual.${buildSys};
                            in
                            "file://${manual}/share/doc/nixpkgs/index.html";
                        }
                      ])
                      (lib.mkIf cfg.manuals.nixos.enable [
                        {
                          name = "NixOS Manual";
                          url = "file://${inputs.nixpkgs.htmlDocs.nixosManual.${buildSys}}/share/doc/nixos/index.html";
                        }
                      ])
                      (lib.mkIf cfg.manuals.home-manager.enable [
                        {
                          name = "Home Manager Manual";
                          url = "file://${
                            inputs.home-manager.packages.${buildSys}.docs-html
                          }/share/doc/home-manager/index.xhtml";
                        }
                      ])
                      (lib.mkIf cfg.manuals.nixvim.enable [
                        (
                          let
                            docs = inputs.nixvim.packages.${buildSys}.docs.overrideAttrs (
                              final: prev: {
                                # avoid depends on gcc which is contained in environments
                                buildPhase = prev.buildPhase + "rm $out/env-vars\n";
                              }
                            );
                          in
                          {
                            name = "Nixvim docs";
                            url = "file://${docs}/index.html";
                          }
                        )
                      ])
                      (lib.mkIf cfg.manuals.microvm.enable [
                        {
                          name = "microvm.nix doc";
                          url = "file://${inputs.microvm.packages.${buildSys}.doc}/index.html";
                        }
                      ])
                    ];
                  }
                ];
                SearchEngines.Add = lib.mkIf cfg.search.enable (
                  let
                    IconURL = "file://${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  in
                  [
                    {
                      Name = "NixOS packages";
                      Description = "Search NixOS packages by name or description.";
                      inherit IconURL;
                      URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
                      Alias = "@nixpkg";
                    }
                    {
                      Name = "NixOS options";
                      Description = "Search NixOS options by name or description.";
                      inherit IconURL;
                      URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
                      Alias = "@nixopt";
                    }
                    {
                      Name = "NixOS Wiki";
                      Description = "NixOS Wiki (en)";
                      inherit IconURL;
                      URLTemplate = "https://wiki.nixos.org/w/index.php?title=Special:Search&search={searchTerms}";
                      SuggestURLTemplate = "https://wiki.nixos.org/w/api.php?action=opensearch&search={searchTerms}&namespace=0";
                      Alias = "@nixwiki";
                    }
                  ]
                );
              };
            };
        };
    };
  };

  nixvim = mkEnableModule (
    { pkgs, ... }: {
      plugins = {
        none-ls.sources = {
          formatting = {
            nixfmt = {
              enable = true;
              package = pkgs.nixfmt;
            };
          };
        };
      };
    }
  );
}

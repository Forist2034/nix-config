{
  firefox,
  options,
  vscodium,
  ...
}:
{
  home =
    {
      config,
      pkgs,
      lib,
      inputs,
      info,
      ...
    }:
    {
      options = with lib; {
        develop.nix = {
          enable = mkEnableOption "Nix environment";

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium Nix support";
            helix = {
              enable = mkEnableOption "Helix nix support";
              formatter = {
                enable = options.mkDisableOption "Enable formatter";
              };
            };
            nixvim = {
              enable = mkEnableOption "Neovim nix";
              formatter = {
                enable = options.mkDisableOption "Enable formatter";
              };
            };
          };

          browser = {
            firefox = {
              enable = mkEnableOption "Nix doc";
              bookmarks = {
                nix.enable = options.mkDisableOption "Nix document";
                nixpkgs.enable = options.mkDisableOption "Nixpkgs manual";
                nixos.enable = options.mkDisableOption "Nixos manual";
                home-manager.enable = options.mkDisableOption "Home Manager doc";
                nixvim.enable = options.mkDisableOption "Nixvim doc";
              };
              search.enable = options.mkDisableOption "Nix search engines";
              profiles = firefox.profile.mkOption {
                enable = mkEnableOption "Nix firefox";
              };
            };
          };
        };
      };

      config =
        let
          cfg = config.develop.nix;
        in
        lib.mkIf cfg.enable {

          programs.firefox =
            let
              cfgFF = cfg.browser.firefox;
            in
            lib.mkIf cfgFF.enable {
              policies = {
                ManagedBookmarks = lib.mkMerge [
                  [
                    {
                      name = "Nix manuals";
                      children = lib.mkMerge [
                        (lib.mkIf cfgFF.bookmarks.nix.enable [
                          {
                            name = "Nix Reference Manual";
                            url = "file://${config.nix.package.doc}/share/doc/nix/manual/index.html";
                          }
                        ])
                        (lib.mkIf cfgFF.bookmarks.nixpkgs.enable [
                          {
                            name = "Nixpkgs manual";
                            url =
                              let
                                manual = inputs.nixpkgs.htmlDocs.nixpkgsManual.${info.system};
                              in
                              "file://${manual}/share/doc/nixpkgs/index.html";
                          }
                        ])
                        (lib.mkIf cfgFF.bookmarks.nixos.enable [
                          {
                            name = "NixOS Manual";
                            url = "file://${inputs.nixpkgs.htmlDocs.nixosManual.${info.system}}/share/doc/nixos/index.html";
                          }
                        ])
                      ];
                    }
                  ]
                  (lib.mkIf cfgFF.bookmarks.home-manager.enable [
                    {
                      name = "Home Manager Manual";
                      url = "file://${
                        inputs.home-manager.packages.${info.system}.docs-html
                      }/share/doc/home-manager/index.xhtml";
                    }
                  ])
                  (lib.mkIf cfgFF.bookmarks.nixvim.enable [
                    (
                      let
                        docs = inputs.nixvim.packages.${info.system}.docs.overrideAttrs (
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
                ];
                SearchEngines.Add = lib.mkIf cfgFF.search.enable (
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

          programs.vscodium = vscodium.mkSimpleConfig cfg.editor.vscodium {
            extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];
            userSettings = {
              "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable {
            languages = {
              language = [
                {
                  name = "nix";
                  auto-format = true;
                  formatter = lib.mkIf cfg.editor.helix.formatter.enable {
                    command = "${pkgs.nixfmt}/bin/nixfmt";
                  };
                }
              ];
            };
          };

          programs.nixvim =
            let
              cfgVim = cfg.editor.nixvim;
            in
            lib.mkIf cfgVim.enable {
              plugins = {
                none-ls.sources = {
                  formatting = {
                    nixfmt = lib.mkIf cfgVim.formatter.enable {
                      enable = true;
                      package = pkgs.nixfmt;
                    };
                  };
                };
              };
            };
        };
    };
}

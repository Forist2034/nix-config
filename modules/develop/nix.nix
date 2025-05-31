{
  firefox,
  options,
  vscode,
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
            vscode = vscode.mkSimpleOption "VSCode Nix support";
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
              profiles = firefox.profile.mkOption {
                enable = mkEnableOption "Nix firefox";
                search = {
                  packages = options.mkDisableOption "Nix packages search";
                  options = options.mkDisableOption "Nix options search";
                  wiki = options.mkDisableOption "NixOS wiki search";
                };
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
                            url = "${pkgs.nix.doc}/share/doc/nix/manual/index.html";
                          }
                        ])
                        (lib.mkIf cfgFF.bookmarks.nixpkgs.enable [
                          {
                            name = "Nixpkgs manual";
                            url = "${inputs.nixpkgs.htmlDocs.nixpkgsManual.${info.system}}/share/doc/nixpkgs/manual.html";
                          }
                        ])
                        (lib.mkIf cfgFF.bookmarks.nixos.enable [
                          {
                            name = "NixOS Manual";
                            url = "${inputs.nixpkgs.htmlDocs.nixosManual.${info.system}}/share/doc/nixos/index.html";
                          }
                        ])
                      ];
                    }
                  ]
                  (lib.mkIf cfgFF.bookmarks.home-manager.enable [
                    {
                      name = "Home Manager Manual";
                      url = "${inputs.home-manager.packages.${info.system}.docs-html}/share/doc/home-manager/index.xhtml";
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
                        url = "${docs}/index.html";
                      }
                    )
                  ])
                ];
              };
              profiles = firefox.profile.mkConfig (
                value:
                lib.mkIf value.enable {
                  search.engines =
                    let
                      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                    in
                    {

                      "NixOS packages" = lib.mkIf value.search.packages {
                        description = "Search NixOS packages by name or description.";
                        urls = [
                          {
                            template = "https://search.nixos.org/packages";
                            params = [
                              {
                                name = "query";
                                value = "{searchTerms}";
                              }
                            ];
                          }
                        ];
                        inherit icon;
                        definedAliases = [ "@nixpkg" ];
                      };
                      "NixOS options" = lib.mkIf value.search.options {
                        description = "Search NixOS options by name or description.";
                        urls = [
                          {
                            template = "https://search.nixos.org/options";
                            params = [
                              {
                                name = "query";
                                value = "{searchTerms}";
                              }
                            ];
                          }
                        ];
                        inherit icon;
                        definedAliases = [ "@nixopt" ];
                      };
                      "NixOS Wiki" = lib.mkIf value.search.wiki {
                        description = "NixOS Wiki (en)";
                        urls = [
                          {
                            template = "https://wiki.nixos.org/w/index.php";
                            params = [
                              {
                                name = "title";
                                value = "Special:Search";
                              }
                              {
                                name = "search";
                                value = "{searchTerms}";
                              }
                            ];
                          }
                          {
                            template = "https://wiki.nixos.org/w/api.php";
                            params = [
                              {
                                name = "action";
                                value = "opensearch";
                              }
                              {
                                name = "search";
                                value = "{searchTerms}";
                              }
                              {
                                name = "namespace";
                                value = "0";
                              }
                            ];
                            type = "application/x-suggestions+json";
                          }
                          {
                            template = "https://wiki.nixos.org/w/api.php";
                            params = [
                              {
                                name = "action";
                                value = "opensearch";
                              }
                              {
                                name = "format";
                                value = "xml";
                              }
                              {
                                name = "search";
                                value = "{searchTerms}";
                              }
                              {
                                name = "namespace";
                                value = "0";
                              }
                            ];
                            type = "application/x-suggestions+xml";
                          }
                        ];
                        inherit icon;
                        definedAliases = [ "@nixwiki" ];
                      };
                    };
                }
              ) cfgFF.profiles;
            };

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];
            userSettings = {
              "nix.formatterPath" = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable {
            languages = {
              language = [
                {
                  name = "nix";
                  auto-format = true;
                  formatter = lib.mkIf cfg.editor.helix.formatter.enable {
                    command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
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
                      package = pkgs.nixfmt-rfc-style;
                    };
                  };
                };
              };
            };
        };
    };
}

{
  persist,
  firefox,
  options,
  vscode,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "rust";
    options = {
      enable = lib.mkEnableOption "Rust";
    };
    config = { value, ... }: lib.mkIf value.enable { directories = [ ".cargo" ]; };
  };

  home =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options = with lib; {
        develop.rust = {
          enable = mkEnableOption "Rust environment";

          env.enable = options.mkDisableOption "Rust build tools";

          editor = {
            vscode = vscode.mkSimpleOption "VSCode rust support";
            helix.enable = mkEnableOption "Helix rust support";
            nixvim.enable = mkEnableOption "Neovim rust support";
          };

          browser = {
            firefox = {
              enable = mkEnableOption "Rust doc";
              bookmarks = {
                rustc.enable = options.mkDisableOption "Rust Documentation";
              };
              profiles = firefox.profile.mkOption {
                enable = mkEnableOption "Rust firefox";
                search = {
                  crates = options.mkDisableOption "Crates.io search engine";
                  docsrs = options.mkDisableOption "Docs.rs search engine";
                };
              };
            };
          };
        };
      };

      config =
        let
          cfg = config.develop.rust;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable (
            with pkgs;
            [
              cargo
              rustc
              rustfmt
              clippy
              rust-bindgen
              rust-cbindgen
              cargo-audit
            ]
          );

          programs.firefox =
            let
              cfgFF = cfg.browser.firefox;
            in
            lib.mkIf cfgFF.enable {
              policies.ManagedBookmarks = lib.mkIf cfgFF.bookmarks.rustc.enable [
                {
                  name = "Rust Documentation";
                  url = "${pkgs.rustc.doc}/share/doc/docs/html/index.html";
                }
              ];
              profiles = firefox.profile.mkConfig (
                value:
                lib.mkIf value.enable {
                  search.engines = {
                    "Cargo" = lib.mkIf value.search.crates {
                      description = "Search for crates on crates.io";
                      urls = [
                        {
                          template = "https://crates.io/search";
                          params = [
                            {
                              name = "q";
                              value = "{searchTerms}";
                            }
                          ];
                        }
                      ];
                      definedAliases = [ "@crates" ];
                    };
                    "Docs.rs" = lib.mkIf value.search.docsrs {
                      description = "Search for crate documentation on docs.rs";
                      urls = [
                        {
                          template = "https://docs.rs/releases/search";
                          params = [
                            {
                              name = "query";
                              value = "{searchTerms}";
                            }
                          ];
                        }
                      ];
                      iconUpdateUrl = "https://docs.rs/-/static/favicon.ico";
                      updateInternal = 7 * 24 * 60 * 60;
                      definedAliases = [ "@docsrs" ];
                    };
                  };
                }
              ) cfgFF.profiles;
            };

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = [ pkgs.vscode-extensions.rust-lang.rust-analyzer ];
            userSettings = {
              "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable { extraPackages = [ pkgs.rust-analyzer ]; };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              rustaceanvim = {
                enable = true;
              };
            };
          };
        };
    };
}

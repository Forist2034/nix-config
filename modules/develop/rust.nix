{
  persist,
  firefox,
  options,
  vscodium,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "rust";
    options = {
      enable = lib.mkEnableOption "Rust";
      cargo.enable = lib.mkEnableOption "Cargo persist";
      rustup.enable = lib.mkEnableOption "Rustup persist";
    };
    config =
      { value, ... }:
      lib.mkIf value.enable {
        directories = lib.mkMerge [
          (lib.mkIf value.cargo.enable [ ".cargo" ])
          (lib.mkIf value.rustup.enable [ ".rustup" ])
        ];
      };
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
          pkgs.enable = options.mkDisableOption "Rust packages";

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium rust support";
            helix.enable = mkEnableOption "Helix rust support";
            nixvim.enable = mkEnableOption "Neovim rust support";
          };

          browser = {
            firefox = {
              enable = mkEnableOption "Rust doc";
              bookmarks = {
                rustc.enable = options.mkDisableOption "Rust Documentation";
              };
              search.enable = options.mkDisableOption "Rust Search engines";
              profiles = firefox.profile.mkOption {
                enable = mkEnableOption "Rust firefox";
              };
            };
          };
        };
      };

      config =
        let
          cfg = config.develop.rust;
          visiblePkgs = with pkgs; [
            cargo
            rustc
            rustfmt
            clippy
            rust-bindgen
            rust-cbindgen
            cargo-audit
          ];
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable visiblePkgs;
          home.extraDependencies = lib.mkIf cfg.pkgs.enable (visiblePkgs ++ [ pkgs.rustup ]);

          programs.firefox =
            let
              cfgFF = cfg.browser.firefox;
            in
            lib.mkIf cfgFF.enable {
              policies = {
                ManagedBookmarks = lib.mkIf cfgFF.bookmarks.rustc.enable [
                  {
                    name = "Rust Documentation";
                    url = "file://${pkgs.rustc.doc}/share/doc/docs/html/index.html";
                  }
                ];
                SearchEngines.Add = lib.mkIf cfgFF.search.enable [
                  {
                    Name = "Cargo";
                    Description = "Search for crates on crates.io";
                    URLTemplate = "https://crates.io/search?q={searchTerms}";
                    Alias = "@crates";
                  }
                  {
                    Name = "Docs.rs";
                    Description = "Search for crate documentation on docs.rs";
                    URLTemplate = "https://docs.rs/releases/search?query={searchTerms}";
                    IconURL = "https://docs.rs/-/static/favicon.ico";
                    Alias = "@docsrs";
                  }
                ];
              };
            };

          programs.vscodium = vscodium.mkSimpleConfig cfg.editor.vscodium {
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

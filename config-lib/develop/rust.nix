{ devLib, local-lib, ... }:
let
  name = "rust";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Rust";
  };
in
{
  inherit name;
  submodules = {
    firefox.global =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        options = {
          cfglib.develop.rust = with lib; {
            enable = mkEnableOption "Rust doc";
            docs = {
              rustc.enable = local-lib.options.mkDisableOption "Rust Documentation";
            };
            search.enable = local-lib.options.mkDisableOption "Rust Search engines";
          };
        };
        config =
          let
            cfg = config.cfglib.develop.rust;
          in
          lib.mkIf cfg.enable {
            policies.ManagedBookmarks = lib.mkIf cfg.docs.rustc.enable [
              {
                name = "Rust Documentation";
                url = "file://${pkgs.rustc.doc}/share/doc/docs/html/index.html";
              }
            ];
            policies.SearchEngines.Add = lib.mkIf cfg.search.enable [
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
    helix = mkEnableModule (
      { pkgs, ... }: {
        extraPackages = [ pkgs.rust-analyzer ];
      }
    );
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [ pkgs.vscode-extensions.rust-lang.rust-analyzer ];
        userSettings = {
          "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        rustaceanvim = {
          enable = true;
        };
      };
    }
  );

  home =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options = with lib; {
        cfglib.develop.rust = {
          enable = mkEnableOption "Rust environment";
          pkgs.enable = local-lib.options.mkDisableOption "Rust packages";
        };
      };

      config =
        let
          cfg = config.cfglib.develop.rust;
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
          home.packages = visiblePkgs;
          home.extraDependencies = lib.mkIf cfg.pkgs.enable (visiblePkgs ++ [ pkgs.rustup ]);
        };
    };
}

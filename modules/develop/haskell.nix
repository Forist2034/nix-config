{
  persist,
  firefox,
  vscodium,
  options,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "haskell";
    options = {
      cabal = {
        enable = lib.mkEnableOption "Cabal for haskell";
        config.enable = lib.mkEnableOption "Cabal config";
        packages.enable = lib.mkEnableOption "Cabal packages";
        store.enable = lib.mkEnableOption "Cabal store";
      };
    };
    config =
      { value, ... }:
      # mount separately allow files to be shared
      lib.mkIf value.cabal.enable {
        files = if value.cabal.config.enable then [ ".cabal/config" ] else [ ];
        directories =
          (if value.cabal.packages.enable then [ ".cabal/packages" ] else [ ])
          ++ (if value.cabal.store.enable then [ ".cabal/store" ] else [ ]);
      };
  };

  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        develop.haskell = {
          enable = mkEnableOption "Haskell environment";

          env = {
            cabal.enable = options.mkDisableOption "Cabal environment";
          };

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium haskell support";
            helix.enable = mkEnableOption "Helix haskell support";
            nixvim.enable = mkEnableOption "Neovim haskell support";
          };

          browser = {
            firefox = {
              enable = mkEnableOption "Haskell doc";
              bookmarks = {
                ghc.enable = options.mkDisableOption "GHC document";
                packages = mkOption {
                  type = types.listOf types.package;
                  default = [ ];
                };
              };
              search.enable = options.mkDisableOption "Haskell search engines";
              profiles = firefox.profile.mkOption {
                enable = mkEnableOption "Haskell firefox";
              };
            };
          };
        };
      };

      config =
        let
          cfg = config.develop.haskell;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.cabal.enable (
            with pkgs;
            [
              ghc
              cabal-install
              haskell-language-server
            ]
          );

          programs.firefox =
            let
              ffCfg = cfg.browser.firefox;
            in
            lib.mkIf ffCfg.enable {
              policies.ManagedBookmarks = lib.mkMerge [
                (lib.mkIf ffCfg.bookmarks.ghc.enable [
                  {
                    name = "GHC Documentation";
                    url = "file://${pkgs.ghc.doc}/share/doc/ghc/html/index.html";
                  }
                ])
                [
                  {
                    name = "Haskell packages";
                    children = builtins.map (p: {
                      inherit (p) name;
                      url = "file://${p.doc}/share/doc/${p.name}/html/index.html";
                    }) ffCfg.bookmarks.packages;
                  }
                ]
              ];
              policies.SearchEngines.Add = lib.mkIf ffCfg.search.enable [
                {
                  Name = "Hackage";
                  Description = "Search for Haskell packages on Hackage";
                  URLTemplate = "https://hackage.haskell.org/packages/search?terms={searchTerms}";
                  Alias = "@hackage";
                }
                {
                  Name = "Hoogle";
                  Description = "Haskell API Search";
                  URLTemplate = "https://hoogle.haskell.org/?hoogle={searchTerms}";
                  Alias = "@hoogle";
                }
              ];
            };

          programs.vscodium = vscodium.mkSimpleConfig cfg.editor.vscodium {
            extensions = with pkgs.vscode-extensions; [
              justusadam.language-haskell # syntax highlight
              haskell.haskell
            ];
            userSettings = {
              "haskell.serverExecutablePath" =
                "${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper";
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable {
            extraPackages = [ pkgs.haskell-language-server ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.hls = {
                enable = true;
                installGhc = false;
              };
            };
          };
        };
    };
}

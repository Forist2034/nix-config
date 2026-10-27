{
  devLib,
  local-lib,
  ...
}:
let
  name = "haskell";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Haskell";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule (
      { pkgs, ... }: {
        extraPackages = [ pkgs.haskell-language-server ];
      }
    );

    firefox.global =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        options = {
          cfglib.develop.haskell = with lib; {
            enable = mkEnableOption "Haskell doc";
            docs = {
              ghc.enable = local-lib.options.mkDisableOption "GHC documents";
              packages = mkOption {
                type = types.listOf types.package;
                default = [ ];
              };
            };
            search.enable = local-lib.options.mkDisableOption "Haskell search engines";
          };
        };
        config =
          let
            cfg = config.cfglib.develop.haskell;
          in
          lib.mkIf cfg.enable {
            policies.ManagedBookmarks = lib.mkMerge [
              (lib.mkIf cfg.docs.ghc.enable [
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
                  }) cfg.docs.packages;
                }
              ]
            ];
            policies.SearchEngines.Add = lib.mkIf cfg.search.enable [
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
      };

    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = with pkgs.vscode-extensions; [
          justusadam.language-haskell # syntax highlight
          haskell.haskell
        ];
        userSettings = {
          "haskell.serverExecutablePath" =
            "${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper";
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.hls = {
          enable = true;
          installGhc = false;
        };
      };
    }
  );

  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        cfglib.develop.haskell = {
          enable = mkEnableOption "Haskell environment";

          cabal.enable = local-lib.options.mkDisableOption "Cabal environment";
        };
      };

      config =
        let
          cfg = config.cfglib.develop.haskell;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.cabal.enable (
            with pkgs;
            [
              ghc
              cabal-install
              haskell-language-server
            ]
          );
        };
    };
}

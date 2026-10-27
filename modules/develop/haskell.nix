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
}

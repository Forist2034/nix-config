{ devLib, ... }:
let
  name = "agda";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Agda";
  };
in
{
  inherit name;

  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = pkgs.nix4vscode.forVscode [
          "banacorn.agda-mode"
        ];
      }
    );
  };

  nixvim = mkEnableModule (
    { pkgs, ... }: {
      extraPlugins = [
        {
          plugin = pkgs.vimPlugins.cornelis;
          config = "let g:cornelis_use_global_binary = 1";
        }
      ];
      extraPackages = [ pkgs.cornelis ];
    }
  );

  home = mkEnableModule (
    { pkgs, ... }: {
      home.packages = [
        pkgs.agda
        # unmaintained
        # pkgs.agda-pkg
      ];
    }
  );
}

{ devLib, ... }:
let
  name = "typst";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Typst";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [ pkgs.vscode-extensions.myriad-dreamin.tinymist ];
        userSettings = {
          "tinymist.serverPath" = "${pkgs.tinymist}/bin/tinymist";
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.tinymist = {
          enable = true;
        };
        typst-vim = {
          enable = true;
        };
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }: {
      home.packages = [
        pkgs.typst
        pkgs.typstyle
      ];
    }
  );
}

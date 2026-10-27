{ devLib, ... }:
let
  name = "css";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "CSS";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule (
      { pkgs, ... }: {
        extraPackages = [ pkgs.vscode-langservers-extracted ];
      }
    );

    vscodium = mkEnableModule (
      { ... }: {
        cfglib.develop.prettier = {
          enable = true;
          languages = {
            css = true;
            scss = true;
            sass = true;
            less = true;
          };
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.cssls = {
          enable = true;
        };
      };

      cfglib.develop.prettier = {
        enable = true;
        languages = {
          css = true;
          scss = true;
          sass = true;
          less = true;
        };
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.sass
        pkgs.lessc
      ];
    }
  );
}

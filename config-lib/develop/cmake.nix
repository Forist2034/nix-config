{ devLib, ... }:
let
  name = "cmake";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "CMake";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = with pkgs.vscode-extensions; [
          ms-vscode.cmake-tools
        ];
      }
    );

    helix = mkEnableModule (
      { pkgs, ... }: {
        extraPackages = [ pkgs.cmake-language-server ];
      }
    );
  };
  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.cmake = {
          enable = true;
        };
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = [ pkgs.cmake ];
    }
  );
}

{ devLib, ... }:
let
  name = "html";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "HTML";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule ({ pkgs, ... }: { extraPackages = [ pkgs.vscode-langservers-extracted ]; });
    vscodium = mkEnableModule (
      { ... }: {
        cfglib.develop.prettier = {
          enable = true;
          languages.html = true;
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.html = {
          enable = true;
        };
      };

      cfglib.develop.prettier = {
        enable = true;
        languages.html = true;
      };
    }
  );
}

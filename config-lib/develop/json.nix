{ devLib, ... }:
let
  name = "json";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "JSON";
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
            json = true;
            jsonc = true;
          };
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.jsonls = {
          enable = true;
        };
      };

      cfglib.develop.prettier = {
        enable = true;
        languages = {
          json = true;
        };
      };
    }
  );
}

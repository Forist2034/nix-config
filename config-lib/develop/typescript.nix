{ devLib, ... }:
let
  name = "typescript";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "TypeScript";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule (
      { pkgs, ... }: {
        extraPackages = [ pkgs.typescript-language-server ];
      }
    );
    vscodium = mkEnableModule (
      { ... }: {
        cfglib.develop.prettier = {
          enable = true;
          languages = {
            typescript = true;
            typescriptreact = true;
          };
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.ts_ls = {
          enable = true;
        };
      };

      cfglib.develop.prettier = {
        enable = true;
        languages = {
          typescript = true;
          typescriptreact = true;
        };
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = [ pkgs.typescript ];
    }
  );
}

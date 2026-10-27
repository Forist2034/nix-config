{ devLib, ... }:
let
  name = "graphql";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "GraphQL";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule (
      { pkgs, ... }: {
        extraPackages = [ pkgs.graphql-language-service-cli ];
      }
    );

    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = with pkgs.vscode-extensions; [
          graphql.vscode-graphql
          graphql.vscode-graphql-syntax
        ];

        cfglib.develop.prettier = {
          enable = true;
          languages.graphql = true;
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.graphql = {
          enable = true;
        };
      };

      cfglib.develop.prettier = {
        enable = true;
        languages.graphql = true;
      };
    }
  );
}

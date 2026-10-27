{ devLib, ... }:
let
  name = "dhall";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Dhall";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule ({ pkgs, ... }: { extraPackages = [ pkgs.dhall-lsp-server ]; });

    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = with pkgs.vscode-extensions; [
          dhall.vscode-dhall-lsp-server
          dhall.dhall-lang
        ];
        userSettings = {
          "vscode-dhall-lsp-server.executable" = "${pkgs.dhall-lsp-server}/bin/dhall-lsp-server";
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.dhall_lsp_server = {
          enable = true;
        };
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        dhall
        dhall-json
        dhall-yaml
      ];
    }
  );
}

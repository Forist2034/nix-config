{ devLib, ... }:
let
  name = "toml";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Toml";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule ({ pkgs, ... }: { extraPackages = [ pkgs.taplo ]; });
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [ pkgs.vscode-extensions.tamasfe.even-better-toml ];
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.taplo = {
          enable = true;
        };
      };
    }
  );
}

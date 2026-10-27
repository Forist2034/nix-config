{ devLib, ... }:
let
  name = "nushell";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Nushell";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [ pkgs.vscode-extensions.thenuprojectcontributors.vscode-nushell-lang ];
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      lsp.servers.nushell.enable = true;
    }
  );
}

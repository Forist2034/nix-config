{ devLib, ... }:
let
  name = "meson";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Meson";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [
          pkgs.vscode-extensions.mesonbuild.mesonbuild
        ];
        userSettings = {
          "mesonbuild.formatting.enabled" = true;
          "mesonbuild.linter.muon.enabled" = true;
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { pkgs, ... }: {
      # FIXME: mesonlsp is unmaintained
      lsp.servers.mesonlsp = {
        enable = true;
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.meson
        pkgs.muon
      ];
    }
  );
}

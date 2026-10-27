{ devLib, ... }:
let
  name = "maven";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Maven";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [
          pkgs.vscode-extensions.vscjava.vscode-maven
        ];
      }
    );
  };

  home = mkEnableModule (
    { pkgs, ... }: {
      home.packages = [ pkgs.maven ];
    }
  );
}

{ devLib, ... }:
let
  name = "gradle";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Gradle";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [
          pkgs.vscode-extensions.vscjava.vscode-gradle
        ];
      }
    );
  };

  home = mkEnableModule (
    { pkgs, ... }: {
      home.packages = [ pkgs.gradle ];
    }
  );
}

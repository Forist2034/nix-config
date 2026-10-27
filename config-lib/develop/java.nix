{
  devLib,
  local-lib,
  ...
}:
let
  name = "java";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Java";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule ({ pkgs, ... }: { extraPackages = [ pkgs.jdt-language-server ]; });

    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = with pkgs.vscode-extensions; [
          redhat.java
          vscjava.vscode-java-debug
          vscjava.vscode-java-test
          vscjava.vscode-java-dependency
        ];
        userSettings = {
          "java.jdt.ls.java.home" = "${pkgs.jdk}/lib/openjdk";
        };

      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        jdtls = {
          enable = true;
        };
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.jdk
      ];
    }
  );
}

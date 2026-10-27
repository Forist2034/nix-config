{ devLib, ... }:
let
  name = "scala";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Scala";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [
          pkgs.vscode-extensions.scala-lang.scala
        ]
        ++ pkgs.nix4vscode.forOpenVsx [
          # package in nixpkgs is outdated
          "scalameta.metals"
        ];
        userSettings = {
          "metals.javaHome" = "${pkgs.jdk.outPath}/lib/openjdk";
          "metals.millScript" = "mill";
          "files.watcherExclude" = {
            "**/.bloop" = true;
            "**/.metals" = true;
            "**/.ammonite" = true;
          };
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { pkgs, ... }: {
      extraPlugins = [ pkgs.vimPlugins.nvim-metals ];
      plugins = {
        lsp.servers.metals = {
          enable = true;
        };
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        scala_3
        scala-cli
        scalafmt
        scalafix
        coursier
        metals
        sbt
        mill
      ];
    }
  );
}

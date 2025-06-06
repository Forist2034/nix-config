{
  persist,
  options,
  vscode,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "coursier";
    options = {
      enable = lib.mkEnableOption "Coursier";
    };
    config = { value, ... }: lib.mkIf value.enable { directories = [ ".cache/coursier" ]; };
  };

  home =
    {
      config,
      pkgs,
      inputs,
      lib,
      info,
      ...
    }:
    {
      options = with lib; {
        develop.scala = {
          enable = mkEnableOption "Scala environment";

          env.enable = options.mkDisableOption "Scala build tools";

          editor = {
            vscode = vscode.mkSimpleOption "VSCode scala support";
            nixvim.enable = mkEnableOption "Neovim scala support";
          };
        };
      };

      config =
        let
          cfg = config.develop.scala;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable (
            with pkgs;
            [
              scala_3
              scala-cli
              scalafmt
              scalafix
              coursier
              metals
              sbt
              mill
            ]
          );

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions =
              [
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
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            extraPlugins = [ pkgs.vimPlugins.nvim-metals ];
            plugins = {
              lsp.servers.metals = {
                enable = true;
              };
            };
          };
        };
    };
}

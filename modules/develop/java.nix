{
  persist,
  options,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "java";
    options = {
      gradle.enable = lib.mkEnableOption "Gradle";
      maven.enable = lib.mkEnableOption "Maven";
    };
    config =
      { value, ... }:
      lib.mkMerge [
        (lib.mkIf value.gradle.enable { directories = [ ".gradle" ]; })
        (lib.mkIf value.maven.enable { directories = [ ".m2" ]; })
      ];
  };
  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        develop.java = {
          enable = mkEnableOption "Java environment";

          env = {
            enable = options.mkDisableOption "Java build tools";
            gradle.enable = options.mkDisableOption "Gradle";
            maven.enable = options.mkDisableOption "Maven";
          };

          editor = {
            vscode = {
              enable = mkEnableOption "VSCode Java support";
              gradle.enable = options.mkDisableOption "VSCode Gradle support";
              maven.enable = options.mkDisableOption "VSCode Maven support";
            };
            helix.enable = mkEnableOption "Helix Java support";
            # TODO: enable nixvim when jdt-language-server is supported
            # nixvim.enable = mkEnableOption "Nixvim Java support";
          };
        };
      };

      config =
        let
          cfg = config.develop.java;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [
            pkgs.jdk
            (lib.mkIf cfg.env.gradle.enable pkgs.gradle)
            (lib.mkIf cfg.env.maven.enable pkgs.maven)
          ];

          programs.vscode = lib.mkIf cfg.editor.vscode.enable {
            extensions = with pkgs.vscode-extensions; [
              redhat.java
              vscjava.vscode-java-debug
              vscjava.vscode-java-test
              vscjava.vscode-java-dependency
              (lib.mkIf cfg.editor.vscode.gradle.enable vscjava.vscode-gradle)
              (lib.mkIf cfg.editor.vscode.maven.enable vscjava.vscode-maven)
            ];
            userSettings = {
              "java.jdt.ls.java.home" = "${pkgs.jdk}/lib/openjdk";
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable { extraPackages = [ pkgs.jdt-language-server ]; };
        };
    };
}

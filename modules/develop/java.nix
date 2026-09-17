{
  persist,
  options,
  lib,
  vscodium,
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
      inputs,
      pkgs,
      info,
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
            vscodium = {
              enable = mkEnableOption "VSCodium Java support";
              profiles = vscodium.profile.mkOption {
                enable = mkEnableOption "VSCodium support in profile";
                gradle.enable = options.mkDisableOption "VSCodium Gradle support";
                maven.enable = options.mkDisableOption "VSCodium Maven support";
              };
            };
            helix.enable = mkEnableOption "Helix Java support";
            nixvim.enable = mkEnableOption "Nixvim Java support";
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

          programs.vscodium = lib.mkIf cfg.editor.vscodium.enable {
            profiles = vscodium.profile.mkConfig cfg.editor.vscodium.profiles (
              value:
              lib.mkIf value.enable {
                extensions = with pkgs.vscode-extensions; [
                  redhat.java
                  vscjava.vscode-java-debug
                  vscjava.vscode-java-test
                  vscjava.vscode-java-dependency
                  (lib.mkIf value.gradle.enable vscjava.vscode-gradle)
                  (lib.mkIf value.maven.enable vscjava.vscode-maven)
                ];
                userSettings = {
                  "java.jdt.ls.java.home" = "${pkgs.jdk}/lib/openjdk";
                };
              }
            );
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable { extraPackages = [ pkgs.jdt-language-server ]; };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              jdtls = {
                enable = true;
                settings = {
                  cmd =
                    let
                      home = config.home.homeDirectory;
                    in
                    [
                      "jdtls"
                      "-configuration"
                      "${home}/.cache/jdtls/config"
                      "-data"
                      "${home}/.cache/jdtls/workspace"
                    ];
                };
              };
            };
          };
        };
    };
}

{ options, vscode, ... }:
{
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
        develop.kotlin = {
          enable = mkEnableOption "Kotlin environment";

          env = {
            enable = options.mkDisableOption "Kotlin build tools";
            native.enable = mkEnableOption "Kotlin native tools";
          };

          editor = {
            vscode = vscode.mkSimpleOption "VSCode Kotlin support";
            helix.enable = mkEnableOption "Helix Kotlin support";
            nixvim.enable = mkEnableOption "Nixvim Kotlin support";
          };
        };
      };

      config =
        let
          cfg = config.develop.kotlin;

          kotlin-debug-adapter = pkgs.callPackage ./kotlin/kotlin-debug-adapter.nix { };
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable (
            with pkgs;
            [
              kotlin
              detekt
              ktfmt
              (lib.mkIf cfg.env.native.enable kotlin-native)
            ]
          );

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = [
              inputs.nix-vscode-extensions.extensions.${info.system}.vscode-marketplace.fwcd.kotlin
            ];
            userSettings = {
              "kotlin.java.home" = "${pkgs.jdk}/lib/openjdk";
              "kotlin.languageServer.path" = "${pkgs.kotlin-language-server}/bin/kotlin-language-server";
              "kotlin.debugAdapter.path" = "${kotlin-debug-adapter}/bin/kotlin-debug-adapter";
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable {
            extraPackages = [ pkgs.kotlin-language-server ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.kotlin_language_server = {
                enable = true;
              };
            };
          };
        };
    };
}

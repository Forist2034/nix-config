{ devLib, ... }:
let
  name = "kotlin";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Kotlin";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule (
      { pkgs, ... }: {
        extraPackages = [ pkgs.kotlin-language-server ];
      }
    );
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = pkgs.nix4vscode.forOpenVsx [
          "fwcd.kotlin"
        ];
        userSettings =
          let
            kotlin-debug-adapter = pkgs.callPackage ./kotlin/kotlin-debug-adapter.nix { };
          in
          {
            "kotlin.java.home" = "${pkgs.jdk}/lib/openjdk";
            "kotlin.languageServer.path" = "${pkgs.kotlin-language-server}/bin/kotlin-language-server";
            "kotlin.debugAdapter.path" = "${kotlin-debug-adapter}/bin/kotlin-debug-adapter";
          };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.kotlin_language_server = {
          enable = true;
        };
      };
    }
  );

  home =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options = {
        cfglib.develop.kotlin = {
          enable = lib.mkEnableOption "Kotlin environment";

          native.enable = lib.mkEnableOption "Kotlin native tools";
        };
      };

      config =
        let
          cfg = config.cfglib.develop.kotlin;
        in
        lib.mkIf cfg.enable {
          home.packages = with pkgs; [
            kotlin
            detekt
            ktfmt
            (lib.mkIf cfg.native.enable kotlin-native)
          ];
        };
    };
}

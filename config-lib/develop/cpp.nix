{ devLib, ... }:
let
  name = "cpp";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "C/Cpp";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule ({ pkgs, ... }: { extraPackages = [ pkgs.clang-tools ]; });

    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = with pkgs.vscode-extensions; [ llvm-vs-code-extensions.vscode-clangd ];
        userSettings = {
          "clangd.path" = "${pkgs.clang-tools}/bin/clangd";
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.clangd = {
          enable = true;
        };
        clangd-extensions = {
          enable = true;
        };
      };
    }
  );

  home =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options = with lib; {
        cfglib.develop.cpp = {
          enable = mkEnableOption "C/Cpp Support";

          gcc.enable = mkEnableOption "Gcc support";
          clang.enable = mkEnableOption "Clang support";
        };
      };

      config =
        let
          cfg = config.cfglib.develop.cpp;
        in
        lib.mkIf cfg.enable {
          home.packages =
            with pkgs;
            lib.mkMerge [
              (lib.mkIf cfg.gcc.enable [ gcc ])
              (lib.mkIf cfg.clang.enable [ clang ])
            ];
        };
    };
}

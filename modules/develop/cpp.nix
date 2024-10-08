{ ... }:
{
  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        develop.cpp = {
          enable = mkEnableOption "C/Cpp Support";

          env = {
            gcc.enable = mkEnableOption "Gcc support";
            clang.enable = mkEnableOption "Clang support";
          };

          editor = {
            vscode.enable = mkEnableOption "VSCode c/c++ support";
            helix.enable = mkEnableOption "Helix c/c++ support";
            nixvim.enable = mkEnableOption "Neovim nix c/c++ support";
          };
        };
      };

      config =
        let
          cfg = config.develop.cpp;
        in
        lib.mkIf cfg.enable {
          home.packages =
            with pkgs;
            lib.mkMerge [
              (lib.mkIf cfg.env.gcc.enable [ gcc ])
              (lib.mkIf cfg.env.clang.enable [ clang ])
            ];

          programs.vscode = lib.mkIf cfg.editor.vscode.enable {
            extensions = with pkgs.vscode-extensions; [ llvm-vs-code-extensions.vscode-clangd ];
            userSettings = {
              "clangd.path" = "${pkgs.clang-tools}/bin/clangd";
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable { extraPackages = [ pkgs.clang-tools ]; };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.clangd = {
                enable = true;
              };
              clangd-extensions = {
                enable = true;
              };
            };
          };
        };
    };
}

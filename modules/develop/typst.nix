{ options, ... }: {
  home = { config, pkgs, lib, ... }: {
    options = with lib; {
      develop.typst = {
        enable = mkEnableOption "Typst support";

        env.enable = options.mkDisableOption "Typst build tools";

        editor = {
          vscode.enable = mkEnableOption "VSCode Typst support";
          nixvim.enable = mkEnableOption "Neovim nix typst support";
        };
      };
    };

    config = let cfg = config.develop.typst;
    in lib.mkIf cfg.enable {
      home.packages = lib.mkIf cfg.env.enable [ pkgs.typst pkgs.typst-fmt ];

      programs.vscode = lib.mkIf cfg.editor.vscode.enable {
        extensions = [ pkgs.vscode-extensions.nvarner.typst-lsp ];
        userSettings = {
          "typst-lsp.serverPath" = "${pkgs.typst-lsp}/bin/typst-lsp";
        };
      };

      programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
        plugins = {
          lsp.servers.typst-lsp = { enable = true; };
          typst-vim = { enable = true; };
        };
      };
    };
  };
}

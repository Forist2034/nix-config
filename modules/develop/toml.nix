{ ... }: {
  home = { config, pkgs, lib, ... }: {
    options = with lib; {
      develop.toml = {
        enable = mkEnableOption "Toml support";

        editor = {
          vscode.enable = mkEnableOption "Toml vscode support";
          helix.enable = mkEnableOption "Helix toml support";
          nixvim.enable = mkEnableOption "Neovim nix toml support";
        };
      };
    };

    config = let cfg = config.develop.toml;
    in lib.mkIf cfg.enable {
      programs.vscode = lib.mkIf cfg.editor.vscode.enable {
        extensions = [ pkgs.vscode-extensions.tamasfe.even-better-toml ];
      };

      programs.helix = lib.mkIf cfg.editor.helix.enable {
        languages.language-server.taplo = {
          command = "${pkgs.taplo}/bin/taplo";
        };
      };

      programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
        plugins = { lsp.servers.taplo = { enable = true; }; };
      };
    };
  };
}

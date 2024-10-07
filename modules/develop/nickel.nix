{ options, ... }:
{
  home =
    {
      config,
      pkgs,
      lib,
      inputs,
      info,
      ...
    }:
    {
      options = with lib; {
        develop.nickel = {
          enable = mkEnableOption "Nickel support";

          env.enable = options.mkDisableOption "Nickel tools";

          editor = {
            vscode.enable = mkEnableOption "VSCode Nickel support";
            helix.enable = mkEnableOption "Helix Nickel support";
            nixvim.enable = mkEnableOption "Nixvim Nickel support";
          };
        };
      };

      config =
        let
          cfg = config.develop.nickel;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [ pkgs.nickel ];

          programs.vscode = lib.mkIf cfg.editor.vscode.enable {
            extensions = [
              inputs.nix-vscode-extensions.extensions.${info.system}.vscode-marketplace.tweag.vscode-nickel
            ];
            userSettings = {
              "nls.server.path" = "${pkgs.nls}/bin/nls";
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable {
            languages.language-server.nls = {
              command = "${pkgs.nls}/bin/nls";
            };
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              # TODO: enable nickel-ls when supported
              # lsp.servers.nickel-ls = {
              #   enable = true;
              # };

              treesitter.grammarPackages = [ pkgs.tree-sitter-grammars.tree-sitter-nickel ];
            };
          };
        };
    };
}

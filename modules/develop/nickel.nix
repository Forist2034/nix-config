{ options, vscodium, ... }:
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
            vscodium = vscodium.mkSimpleOption "VSCodium Nickel support";
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

          programs.vscodium = vscodium.mkSimpleConfig cfg.editor.vscodium {
            extensions = pkgs.nix4vscode.forVscode [
              "tweag.vscode-nickel"
            ];
            userSettings = {
              "nls.server.path" = "${pkgs.nls}/bin/nls";
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable { extraPackages = [ pkgs.nls ]; };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            extraPlugins = [ pkgs.vimPlugins.vim-nickel ];
            plugins = {
              lsp.servers.nickel_ls = {
                enable = true;
              };

              treesitter.grammarPackages = [ pkgs.tree-sitter-grammars.tree-sitter-nickel ];
            };
          };
        };
    };
}

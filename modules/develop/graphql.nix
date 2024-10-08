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
        develop.graphql = {
          enable = mkEnableOption "GraphQL environment";

          editor = {
            vscode.enable = mkEnableOption "VSCode GraphQL support";
            helix.enable = mkEnableOption "Helix GraphQL support";
            nixvim.enable = mkEnableOption "Neovim GraphQL support";
          };
        };
      };

      config =
        let
          cfg = config.develop.graphql;
        in
        lib.mkIf cfg.enable {
          programs.vscode = lib.mkIf cfg.editor.vscode.enable {
            extensions = with pkgs.vscode-extensions; [
              graphql.vscode-graphql
              graphql.vscode-graphql-syntax
            ];
          };

          develop.prettier =
            let
              editor = cfg.editor;
            in
            {
              enable = editor.vscode.enable || editor.helix.enable || editor.nixvim.enable;
              editor = {
                vscode = lib.mkIf editor.vscode.enable {
                  enable = true;
                  languages.graphql = true;
                };
                nixvim = lib.mkIf editor.nixvim.enable {
                  enable = true;
                  languages.graphql = true;
                };
              };
            };

          programs.helix = lib.mkIf cfg.editor.helix.enable {
            extraPackages = [ pkgs.nodePackages.graphql-language-service-cli ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.graphql = {
                enable = true;
              };
            };
          };
        };
    };
}

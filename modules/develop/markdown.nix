{ options, ... }:
{
  home =
    { config, lib, ... }:
    {
      options = with lib; {
        develop.markdown = {
          enable = mkEnableOption "Markdown support";

          editor = {
            vscode.enable = mkEnableOption "VSCode Markdown support";
            nixvim.enable = mkEnableOption "Neovim Markdown support";
          };
        };
      };

      config =
        let
          cfg = config.develop.markdown;
        in
        lib.mkIf cfg.enable {
          develop.prettier =
            let
              editor = cfg.editor;
            in
            {
              enable = editor.vscode.enable || editor.nixvim.enable;
              editor = {
                vscode = lib.mkIf editor.vscode.enable {
                  enable = true;
                  languages.markdown = true;
                };
                nixvim = lib.mkIf editor.nixvim.enable {
                  enable = true;
                  languages.markdown = true;
                };
              };
            };
        };
    };
}

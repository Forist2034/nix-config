{ options, vscode, ... }:
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
        develop.json = {
          enable = mkEnableOption "JSON support";

          env.enable = options.mkDisableOption "JSON tools";

          editor = {
            vscode = vscode.mkSimpleConfig "VSCode JSON support";
            helix.enable = mkEnableOption "Helix JSON support";
            nixvim.enable = mkEnableOption "Nixvim JSON support";
          };
        };
      };

      config =
        let
          cfg = config.develop.json;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [ pkgs.jq ];

          develop.prettier =
            let
              editor = cfg.editor;
            in
            {
              enable = editor.vscode.enable || editor.nixvim.enable;
              editor = {
                vscode = lib.mkIf editor.vscode.enable {
                  enable = true;
                  profiles = vscode.profile.mkEnableConfig editor.vscode.profiles {
                    enable = true;
                    languages = {
                      json = true;
                      jsonc = true;
                    };
                  };
                };
                nixvim = lib.mkIf editor.nixvim.enable {
                  enable = true;
                  languages = {
                    json = true;
                  };
                };
              };
            };

          programs.helix = lib.mkIf cfg.editor.helix.enable {
            extraPackages = [ pkgs.vscode-langservers-extracted ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.jsonls = {
                enable = true;
              };
            };
          };
        };
    };
}

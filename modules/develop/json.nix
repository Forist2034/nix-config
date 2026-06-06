{ options, vscodium, ... }:
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
            vscodium = vscodium.mkSimpleConfig "VSCodium JSON support";
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
              enable = editor.vscodium.enable || editor.nixvim.enable;
              editor = {
                vscodium = lib.mkIf editor.vscodium.enable {
                  enable = true;
                  profiles = vscodium.profile.mkEnableConfig editor.vscodium.profiles {
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

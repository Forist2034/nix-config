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
        develop.html = {
          enable = mkEnableOption "HTML environment";

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium HTML support";
            helix.enable = mkEnableOption "Helix HTML support";
            nixvim.enable = mkEnableOption "Nixvim HTML support";
          };
        };
      };

      config =
        let
          cfg = config.develop.html;
        in
        lib.mkIf cfg.enable {
          develop.prettier = {
            enable = cfg.editor.vscodium.enable || cfg.editor.nixvim.enable;
            editor = {
              vscodium = lib.mkIf cfg.editor.vscodium.enable {
                enable = true;
                profiles = vscodium.profile.mkEnableConfig cfg.editor.vscodium.profiles {
                  enable = true;
                  languages.html = true;
                };
              };
              nixvim = lib.mkIf cfg.editor.nixvim.enable {
                enable = true;
                languages.html = true;
              };
            };
          };

          programs.helix = lib.mkIf cfg.enable { extraPackages = [ pkgs.vscode-langservers-extracted ]; };

          programs.nixvim = lib.mkIf cfg.enable {
            plugins = {
              lsp.servers.html = {
                enable = true;
              };
            };
          };
        };
    };
}

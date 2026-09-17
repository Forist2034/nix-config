{ options, vscodium, ... }:
{
  home =
    { config, lib, ... }:
    {
      options = with lib; {
        develop.markdown = {
          enable = mkEnableOption "Markdown support";

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium Markdown support";
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
              enable = editor.vscodium.enable || editor.nixvim.enable;
              editor = {
                vscodium = lib.mkIf editor.vscodium.enable {
                  enable = true;
                  profiles = vscodium.profile.mkEnableConfig editor.vscodium.profiles {
                    enable = true;
                    languages.markdown = true;
                  };
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

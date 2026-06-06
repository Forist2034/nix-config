{ options, vscodium, ... }:
{
  home =
    {
      config,
      pkgs,
      inputs,
      lib,
      info,
      ...
    }:
    {
      options = with lib; {
        develop.agda = {
          enable = mkEnableOption "Adga environment";

          env.enable = options.mkDisableOption "Agda build tools";

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium Agda support";
            nixvim.enable = mkEnableOption "Nixvim Agda support";
          };
        };
      };

      config =
        let
          cfg = config.develop.agda;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [
            pkgs.agda
            # unmaintained
            # pkgs.agda-pkg
          ];

          programs.vscodium = vscodium.mkSimpleConfig cfg.editor.vscodium {
            extensions = pkgs.nix4vscode.forVscode [
              "banacorn.agda-mode"
            ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            extraPlugins = [
              {
                plugin = pkgs.vimPlugins.cornelis;
                config = "let g:cornelis_use_global_binary = 1";
              }
            ];
            extraPackages = [ pkgs.cornelis ];
          };
        };
    };
}

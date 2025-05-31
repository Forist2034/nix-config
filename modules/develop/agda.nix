{ options, vscode, ... }:
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
            vscode = vscode.mkSimpleOption "VSCode Agda support";
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

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = [
              inputs.nix-vscode-extensions.extensions.${info.system}.vscode-marketplace.banacorn.agda-mode
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

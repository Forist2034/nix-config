{ options, vscode, ... }:
{
  home =
    {
      inputs,
      config,
      pkgs,
      lib,
      info,
      ...
    }:
    {
      options = with lib; {
        develop.meson = {
          enable = mkEnableOption "Meson support";
          env.enable = options.mkDisableOption "Meson tools";
          editor = {
            vscode = vscode.mkSimpleOption "VSCode Meson support";
          };
        };
      };

      config =
        let
          cfg = config.develop.meson;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [ pkgs.meson ];

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = [
              pkgs.vscode-extensions.mesonbuild.mesonbuild
            ];
          };
        };
    };
}

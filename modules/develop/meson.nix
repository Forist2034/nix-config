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
            nixvim.enable = mkEnableOption "Nixvim Meson support";
          };
        };
      };

      config =
        let
          cfg = config.develop.meson;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [
            pkgs.meson
            pkgs.muon
          ];

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = [
              pkgs.vscode-extensions.mesonbuild.mesonbuild
            ];
            userSettings = {
              "mesonbuild.formatting.enabled" = true;
              "mesonbuild.linter.muon.enabled" = true;
            };
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            # FIXME: mesonlsp is unmaintained
            lsp.servers.mesonlsp = {
              enable = true;
            };
          };
        };
    };
}

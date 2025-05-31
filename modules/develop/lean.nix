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
        develop.lean = {
          enable = mkEnableOption "Lean environment";

          env.enable = options.mkDisableOption "Lean build tools";

          editor = {
            vscode = vscode.mkSimpleOption "VSCode Lean support";
            nixvim.enable = mkEnableOption "Nixvim Lean support";
          };
        };
      };

      config =
        let
          cfg = config.develop.lean;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [ pkgs.lean4 ];

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = [
              inputs.nix-vscode-extensions.extensions.${info.system}.vscode-marketplace.leanprover.lean4
            ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lean = {
                enable = true;
              };
            };
          };
        };
    };
}

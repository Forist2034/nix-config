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
        develop.lean = {
          enable = mkEnableOption "Lean environment";

          env.enable = options.mkDisableOption "Lean build tools";

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium Lean support";
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

          programs.vscodium = vscodium.mkSimpleConfig cfg.editor.vscodium {
            extensions = pkgs.nix4vscode.forOpenVsx [
              "leanprover.lean4"
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

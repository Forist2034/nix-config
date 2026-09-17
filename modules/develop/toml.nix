{ vscodium, ... }:
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
        develop.toml = {
          enable = mkEnableOption "Toml support";

          editor = {
            vscodium = vscodium.mkSimpleOption "Toml vscodium support";
            helix.enable = mkEnableOption "Helix toml support";
            nixvim.enable = mkEnableOption "Neovim nix toml support";
          };
        };
      };

      config =
        let
          cfg = config.develop.toml;
        in
        lib.mkIf cfg.enable {
          programs.vscodium = vscodium.mkSimpleConfig cfg.editor.vscodium {
            extensions = [ pkgs.vscode-extensions.tamasfe.even-better-toml ];
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable { extraPackages = [ pkgs.taplo ]; };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.taplo = {
                enable = true;
              };
            };
          };
        };
    };
}

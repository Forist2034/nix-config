{ options, vscodium, ... }:
{
  home =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options = with lib; {
        develop.cmake = {
          enable = mkEnableOption "CMake support";
          env.enable = options.mkDisableOption "CMake tools";
          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium CMake support";
            helix.enable = mkEnableOption "Helix CMake support";
            nixvim.enable = mkEnableOption "Helix CMake support";
          };
        };
      };

      config =
        let
          cfg = config.develop.cmake;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [ pkgs.cmake ];

          programs.vscodium = vscodium.mkSimpleConfig cfg.editor.vscodium {
            extensions = with pkgs.vscode-extensions; [
              ms-vscode.cmake-tools
            ];
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable {
            extraPackages = [ pkgs.cmake-language-server ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.cmake = {
                enable = true;
              };
            };
          };
        };
    };
}

{ options, vscode, ... }:
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
            vscode = vscode.mkSimpleOption "VSCode CMake support";
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

          programs.vscode = vscode.mkSimpleConfig cfg.editor.vscode {
            extensions = with pkgs.vscode-extensions; [
              twxs.cmake
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

{ options, ... }:
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
            vscode.enable = mkEnableOption "VSCode CMake support";
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

          programs.vscode = lib.mkIf cfg.editor.vscode.enable {
            extensions = with pkgs.vscode-extensions; [
              twxs.cmake
              ms-vscode.cmake-tools
            ];
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable {
            languages.language-server.cmake-language-server = {
              command = "${pkgs.cmake-language-server}/bin/cmake-language-server";
            };
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

{
  persist,
  firefox,
  options,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "zig";
    options = {
      enable = lib.mkEnableOption "Zig";
    };
    config = { value, ... }: lib.mkIf value.enable { directories = [ ".cache/zig/p" ]; };
  };

  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        develop.zig = {
          enable = mkEnableOption "Zig environment";

          env.enable = options.mkDisableOption "Zig build tools";

          editor = {
            vscode.enable = mkEnableOption "VSCode Zig support";
            helix.enable = mkEnableOption "Helix Zig support";
            nixvim.enable = mkEnableOption "Neovim Zig support";
          };

          browser = {
            firefox = {
              enable = mkEnableOption "Zig doc";
              bookmarks = {
                zig.enable = options.mkDisableOption "Zig lang reference";
              };
            };
          };
        };
      };

      config =
        let
          cfg = config.develop.zig;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [ pkgs.zig ];

          programs.firefox =
            let
              cfgFF = cfg.browser.firefox;
            in
            lib.mkIf cfgFF.enable {
              policies.ManagedBookmarks = lib.mkIf cfgFF.bookmarks.zig.enable [
                {
                  name = "Zig Language Reference";
                  url = "${pkgs.zig.doc}/share/doc/zig-${pkgs.zig.version}/html/langref.html";
                }
              ];
            };

          programs.vscode = lib.mkIf cfg.editor.vscode.enable {
            extensions = [ pkgs.vscode-extensions.ziglang.vscode-zig ];
            userSettings = {
              "zig.initialSetupDone" = true;
              "zig.checkForUpdate" = false;
              "zig.zls.path" = "${pkgs.zls}/bin/zls";
              "zig.path" = "${pkgs.zig}/bin/zig";
            };
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable { extraPackages = [ pkgs.zls ]; };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.zls = {
                enable = true;
              };
              zig.enable = true;
            };
          };
        };
    };
}

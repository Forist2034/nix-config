{ options, vscodium, ... }:
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
        develop.latex = {
          enable = mkEnableOption "LaTex support";
          env = {
            texlive = {
              full.enable = options.mkDisableOption "Full texlive LaTex build tools";
            };
          };

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium LaTex support";
            helix.enable = mkEnableOption "Helix LaTex support";
            nixvim.enable = mkEnableOption "Neovim LaTex support";
          };
        };
      };

      config =
        let
          cfg = config.develop.latex;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.texlive.full.enable [ pkgs.texlive.combined.scheme-full ];

          programs.vscodium = vscodium.mkSimpleConfig cfg.editor.vscodium {
            extensions = [ pkgs.vscode-extensions.james-yu.latex-workshop ];
          };

          programs.helix = lib.mkIf cfg.editor.helix.enable { extraPackages = [ pkgs.texlab ]; };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.texlab = {
                enable = true;
              };
              vimtex = {
                enable = true;
              };
            };
          };
        };
    };
}

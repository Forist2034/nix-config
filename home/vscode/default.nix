let
  base =
    { pkgs, ... }:
    {
      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;
        userSettings = {
          "editor.fontLigatures" = true;
          "editor.rulers" = [ 80 ];

          "editor.formatOnSave" = true;
          "editor.formatOnType" = true;

          "terminal.integrated.cursorStyle" = "line";

          "extensions.autoUpdate" = false;
        };
      };
    };

  editorconfig =
    { pkgs, ... }:
    {
      programs.vscode.extensions = [ pkgs.vscode-extensions.editorconfig.editorconfig ];
    };

  neovim =
    { pkgs, ... }:
    {
      programs.vscode = {
        extensions = [ pkgs.vscode-extensions.asvetliakov.vscode-neovim ];
        userSettings = {
          "vscode-neovim.neovimExecutablePaths.linux" = "${pkgs.neovim}/bin/nvim";
          "vscode-neovim.neovimClean" = true;
        };
      };
    };

  spell =
    { pkgs, ... }:
    {
      programs.vscode = {
        extensions = [ pkgs.vscode-extensions.streetsidesoftware.code-spell-checker ];
        userSettings = {
          "cSpell.checkOnlyEnabledFileTypes" = false;
        };
      };
    };

  path-complete =
    { pkgs, ... }:
    {
      programs.vscode = {
        extensions = [ pkgs.vscode-extensions.christian-kohler.path-intellisense ];
      };
    };
in
{
  inherit
    base
    editorconfig
    neovim
    spell
    path-complete
    ;

  default =
    { ... }:
    {
      imports = [
        base
        editorconfig
        neovim
        spell
        path-complete
      ];
    };
}

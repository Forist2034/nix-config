{ ... }:
let
  profiles = {
    base =
      name:
      { pkgs, ... }:
      {
        programs.vscodium.profiles.${name} = {
          userSettings = {
            "editor.fontLigatures" = true;
            "editor.rulers" = [ 80 ];

            "editor.formatOnSave" = true;
            "editor.formatOnType" = true;

            "scm.defaultViewMode" = "tree";

            "window.autoDetectColorScheme" = true;

            "terminal.integrated.cursorStyle" = "line";

            "extensions.autoUpdate" = false;
          };
        };
      };
    editorconfig =
      name:
      { pkgs, ... }:
      {
        programs.vscodium.profiles.${name} = {
          extensions = [ pkgs.vscode-extensions.editorconfig.editorconfig ];
        };
      };
    neovim =
      name:
      { pkgs, ... }:
      {
        programs.vscodium.profiles.${name} = {
          extensions = [ pkgs.vscode-extensions.asvetliakov.vscode-neovim ];
          userSettings = {
            "vscode-neovim.neovimExecutablePaths.linux" = "${pkgs.neovim}/bin/nvim";
            "vscode-neovim.neovimClean" = true;
          };
        };
      };
    spell =
      name:
      { pkgs, ... }:
      {
        programs.vscodium.profiles.${name} = {
          extensions = [ pkgs.vscode-extensions.streetsidesoftware.code-spell-checker ];
          userSettings = {
            "cSpell.checkOnlyEnabledFileTypes" = false;
          };
        };
      };
    path-complete =
      name:
      { pkgs, ... }:
      {
        programs.vscodium.profiles.${name} = {
          extensions = [ pkgs.vscode-extensions.christian-kohler.path-intellisense ];
        };
      };
  };
in
{
  inherit profiles;

  home = {
    default =
      { pkgs, ... }:
      {
        imports = builtins.map (p: p "default") [
          profiles.base
          profiles.editorconfig
          profiles.neovim
          profiles.spell
          profiles.path-complete
        ];

        programs.vscodium = {
          enable = true;
        };
      };
  };

}

let
  vscodium =
    let
      profiles = {
        base =
          { pkgs, ... }:
          {
            userSettings = {
              "editor.fontLigatures" = true;
              "editor.rulers" = [ 80 ];

              "editor.formatOnSave" = true;
              "editor.formatOnType" = true;

              "scm.defaultViewMode" = "tree";

              "window.autoDetectColorScheme" = true;

              "terminal.integrated.cursorStyle" = "line";
            };
            enableUpdateCheck = false;
            enableExtensionUpdateCheck = false;
          };
        editorconfig =
          { pkgs, ... }:
          {
            extensions = [ pkgs.vscode-extensions.editorconfig.editorconfig ];
          };
        neovim =
          { pkgs, ... }:
          {
            extensions = [ pkgs.vscode-extensions.asvetliakov.vscode-neovim ];
            userSettings = {
              "vscode-neovim.neovimExecutablePaths.linux" = "${pkgs.neovim}/bin/nvim";
              "vscode-neovim.neovimClean" = true;
            };
          };
        spell =
          { pkgs, ... }:
          {
            extensions = [ pkgs.vscode-extensions.streetsidesoftware.code-spell-checker ];
            userSettings = {
              "cSpell.checkOnlyEnabledFileTypes" = false;
            };
          };
        path-complete =
          { pkgs, ... }:
          {
            extensions = [ pkgs.vscode-extensions.christian-kohler.path-intellisense ];
          };
      };
    in
    {
      inherit profiles;

      default = { ... }: {
        imports = [
          profiles.base
          profiles.editorconfig
          profiles.neovim
          profiles.spell
          profiles.path-complete
        ];
      };
    };
in
{ inputs, ... }:
{

  submodules = { inherit vscodium; };

  home = {
    default = { pkgs, lib, ... }: {
      programs.vscodium = {
        enable = true;
        profiles = {
          default = lib.mkMerge [
            { _module.args = { inherit pkgs; }; }
            vscodium.default
          ];
        };
      };

      nixpkgs.overlays = [ inputs.nix4vscode.overlays.forVscode ];
    };
  };
}

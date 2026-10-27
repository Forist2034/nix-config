{ devLib, ... }:
let
  mkEnableModule = devLib.mkEnableModule {
    name = "nickel";
    descName = "Nickel";
  };
in
{
  submodules = {
    helix = mkEnableModule (
      { pkgs, ... }: {
        extraPackages = [ pkgs.nls ];
      }
    );
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = pkgs.nix4vscode.forVscode [
          "tweag.vscode-nickel"
        ];
        userSettings = {
          "nls.server.path" = "${pkgs.nls}/bin/nls";
        };
      }
    );
  };

  home = mkEnableModule (
    { pkgs, ... }: {
      home.packages = [ pkgs.nickel ];
    }
  );

  nixvim = mkEnableModule (
    { pkgs, ... }: {
      extraPlugins = [ pkgs.vimPlugins.vim-nickel ];
      plugins = {
        lsp.servers.nickel_ls = {
          enable = true;
        };

        treesitter.grammarPackages = [ pkgs.tree-sitter-grammars.tree-sitter-nickel ];
      };
    }
  );
}

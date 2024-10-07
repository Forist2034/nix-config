let
  base =
    { ... }:
    {
      programs.nixvim = {
        enable = true;
        options = {
          number = true;
          expandtab = true;
          tabstop = 2;
          shiftwidth = 2;
          smarttab = true;
          spell = true;
          colorcolumn = [ 80 ];
        };
        colorschemes.catppuccin = {
          enable = true;
          settings.transparent_background = true;
        };
      };
    };
  status.lualine =
    { ... }:
    {
      programs.nixvim = {
        plugins.lualine = {
          enable = true;
        };
      };
    };

  explorer = {
    neo-tree =
      { ... }:
      {
        programs.nixvim = {
          plugins.neo-tree = {
            enable = true;
          };
        };
      };

    nvim-tree =
      { ... }:
      {
        programs.nixvim = {
          plugins.nvim-tree = {
            enable = true;
          };
        };
      };
  };

  git =
    { ... }:
    {
      programs.nixvim = {
        plugins = {
          gitsigns = {
            enable = true;
          };
          neogit = {
            enable = true;
          };
        };
      };
    };

  tree-sitter =
    { pkgs, ... }:
    {
      programs.nixvim = {
        plugins = {
          treesitter = {
            enable = true;
            grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
          };
          treesitter-context = {
            enable = true;
          };
        };
      };
    };

  complete = import ./complete.nix;
in
{
  inherit
    base
    status
    explorer
    tree-sitter
    complete
    ;

  gui = {
    neovide = import ./neovide.nix;
  };

  full =
    { ... }:
    {
      imports = [
        base
        status.lualine
        explorer.neo-tree
        git
        tree-sitter
        complete.default
      ];

      programs.nixvim = {
        colorschemes.catppuccin.settings = {
          integrations = {
            cmp = true;
            gitsigns = true;
            neogit = true;
            neotree = true;
            semantic_tokens = true;
            treesitter = true;
            treesitter_context = true;
          };
        };
      };
    };
}

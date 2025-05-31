let
  base =
    { ... }:
    {
      programs.nixvim = {
        enable = true;
        opts = {
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

  explorer =
    { ... }:
    {
      programs.nixvim = {
        plugins = {
          neo-tree = {
            enable = true;
            # TODO: use default document_symbols when stablized
            sources = [
              "filesystem"
              "buffers"
              "git_status"
              "document_symbols"
            ];
          };
          web-devicons.enable = true;
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
            settings = {
              highlight.enable = true;
              ident.enable = true;
            };
          };
          treesitter-context = {
            enable = true;
          };
        };
      };
    };

  # fuzzy finder
  finder =
    {
      pkgs,
      inputs,
      info,
      ...
    }:
    {
      programs.nixvim = {
        dependencies = {
          fzf = {
            enable = true;
            package = pkgs.skim;
          };
        };
        plugins = {
          fzf-lua = {
            enable = true;
            profile = "skim";
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
        explorer
        git
        tree-sitter
        finder
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

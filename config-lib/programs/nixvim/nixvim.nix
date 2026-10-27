let
  profiles = {
    base = {
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
    status.lualine = {
      plugins.lualine = {
        enable = true;
      };
    };
    explorer = {
      plugins = {
        neo-tree = {
          enable = true;
          # TODO: use default document_symbols when stablized
          settings = {
            sources = [
              "filesystem"
              "buffers"
              "git_status"
              "document_symbols"
            ];
          };
        };
        web-devicons.enable = true;
      };
    };
    git = {
      plugins = {
        gitsigns = {
          enable = true;
        };
        neogit = {
          enable = true;
        };
      };
    };
    tree-sitter = { pkgs, ... }: {
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
    finder = { pkgs, ... }: {
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
    completion = import ./completion.nix;

    gui = {
      neovide = {
        globals = {
          neovide_cursor_animation_length = 0;
          neovide_opacity = 0.8;
        };
      };
    };
  };
in
{
  inherit profiles;

  default = { ... }: {
    imports = with profiles; [
      base
      status.lualine
      explorer
      git
      tree-sitter
      finder
      completion.default
      completion.with-icons

      gui.neovide
    ];

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
    autoCmd = [
      {
        event = [ "VimLeave" ];
        pattern = [ "*" ];
        command = "set guicursor=a:ver25";
      }
    ];

  };
}

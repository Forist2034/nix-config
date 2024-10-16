let
  base =
    { ... }:
    {
      programs.nixvim = {
        plugins = {
          cmp = {
            enable = true;
            settings.mapping =
              let
                select_opts = "{behavior = cmp.SelectBehavior.Select}";
              in
              {
                "<C-b>" = "cmp.mapping.scroll_docs(-4)";
                "<C-f>" = "cmp.mapping.scroll_docs(4)";

                "<Up>" = "cmp.mapping.select_prev_item(${select_opts})";
                "<Down>" = "cmp.mapping.select_next_item(${select_opts})";

                "<C-p>" = "cmp.mapping.select_prev_item(${select_opts})";
                "<C-n>" = "cmp.mapping.select_next_item(${select_opts})";

                "<C-e>" = "cmp.mapping.abort()";

                "<CR>" = "cmp.mapping.confirm({ select = true })";
              };
          };
        };
      };
    };

  luasnip =
    { ... }:
    {
      programs.nixvim = {
        plugins = {
          luasnip = {
            enable = true;
          };
          cmp.settings = {
            snippet.expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';
          };
        };
      };
    };

  lsp =
    { pkgs, ... }:
    {
      programs.nixvim = {
        plugins = {
          lsp = {
            enable = true;
            keymaps.lspBuf = {
              K = "hover";
              S = "signature_help";
              "<Leader>f" = "format";
              "<Leader>r" = "rename";
              gR = "references";
              gD = "declaration";
              gd = "definition";
              gi = "implementation";
              gt = "type_definition";
              "<Leader>ca" = "code_action";
            };
          };
          lsp-format.enable = true;
          nvim-lightbulb = {
            # show code actions
            enable = true;
            settings = {
              sign.enabled = false;
              virtualText.enabled = true;
              autocmd.enabled = true;
            };
          };
          fidget.enable = true; # show lsp notices and progress

          # highlight symbol
          illuminate.enable = true;

          cmp-nvim-lsp.enable = true;
          cmp.settings.sources = [ { name = "nvim_lsp"; } ];
        };

        # TODO: use neovim native inlay hint when api becomes stable
        extraPlugins = [ pkgs.vimPlugins.lsp-inlayhints-nvim ];
        extraConfigLuaPost = builtins.readFile ./inlay-hints.lua;

        # code lens
        keymaps = [
          {
            key = "<Leader>cl";
            action.__raw = "vim.lsp.codelens.run";
            mode = [ "n" ];
          }
          {
            key = "<Leader>do";
            action.__raw = "vim.diagnostic.open_float";
            mode = [ "n" ];
          }
        ];
        autoCmd = [
          {
            event = [
              "CursorHold"
              "CursorHoldI"
            ];
            pattern = "*";
            callback.__raw = ''
              function (ev)
                for _, client in pairs(vim.lsp.get_active_clients({ bufnr = ev.buf })) do
                  if client and client.supports_method("textDocument/codeLens") then
                    vim.lsp.codelens.refresh()
                  end
                end
              end
            '';
          }
        ];
      };
    };

  with-icons =
    { ... }:
    {
      programs.nixvim = {
        plugins.lspkind = {
          enable = true;
        };
      };
    };

  none-ls =
    { ... }:
    {
      programs.nixvim = {
        plugins = {
          none-ls = {
            enable = true;
          };
        };
      };
    };

  path =
    { ... }:
    {
      programs.nixvim = {
        plugins = {
          cmp-path.enable = true;
          cmp.settings.sources = [ { name = "path"; } ];
        };
      };
    };

  buffer =
    { ... }:
    {
      programs.nixvim = {
        plugins = {
          cmp-buffer.enable = true;
          cmp.settings.sources = [ { name = "buffer"; } ];
        };
      };
    };
in
{
  inherit
    base
    luasnip
    lsp
    none-ls
    path
    buffer
    with-icons
    ;

  default =
    { ... }:
    {
      imports = [
        base
        luasnip
        lsp
        none-ls
        path
        buffer
      ];
    };
}

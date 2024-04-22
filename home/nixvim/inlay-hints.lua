local lsp_inlay_hint = require("lsp-inlayhints")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    if not (ev.data and ev.data.client_id) then
      return
    end
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client.supports_method("textDocument/inlayHint") then
      lsp_inlay_hint.on_attach(client, bufnr)
    end
  end
})

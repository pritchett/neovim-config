local M = {}

---@param client vim.lsp.Client
---@param bufnr integer
function M.set_keymaps(client, bufnr)
  bufnr = bufnr or 0
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true, buffer = bufnr }
  local function with_defaults(new_opts) return vim.tbl_extend("error", opts, new_opts) end
  keymap('n', 'gO', function() require('fzf-lua').lsp_document_symbols() end, { desc = "Document Symbols" })
  keymap('n', 'grl', vim.lsp.codelens.run, { desc = "Run Code Lens" })
  keymap('n', '<Leader>ls', '<CMD>FzfLua lsp_live_workspace_symbols<CR>', { desc = "Search Workspace Symbols" })
  keymap('n', 'gre', function()
    local namespace = vim.lsp.diagnostic.get_namespace(client.id)
    vim.diagnostic.setqflist({ namespace = namespace, open = false, severity = vim.diagnostic.severity.ERROR })
    vim.api.nvim_command('botright cwindow')
  end, with_defaults({ desc = "Open Diagnostics" }))
  if client.server_capabilities.selectionRangeProvider then
    -- keymap('n', '<leader>v', require('lsp-selection-range').trigger, with_defaults({ desc = "LSP Selection" }))
    keymap('v', 'v', require('lsp-selection-range').expand, with_defaults({ desc = "Expand selection" }))
  end

  keymap('n', '<leader>h',
    function()
      local inlayhints_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
      vim.lsp.inlay_hint.enable(not inlayhints_enabled, { bufnr = 0 })
    end,
    with_defaults({ desc = "Toggle inlay hints" }))
end

local lsp_id = vim.api.nvim_create_augroup("LSP", {})

function M.on_attach(client, bufnr)
  bufnr = bufnr or 0

  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

  M.set_keymaps(client, bufnr)

  local refresh_code_lens = function()
    if client.server_capabilities.code_lens or client.server_capabilities.codeLensProvider then
      pcall(vim.lsp.codelens.refresh)
    end
  end

  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "InsertLeave" }, {
    buffer = bufnr,
    callback = function()
      refresh_code_lens()
      local ok, gitsigns = pcall(require, 'gitsigns')
      if ok and gitsigns then
        gitsigns.refresh()
      end
    end,
    group = lsp_id
  })

  vim.api.nvim_buf_call(bufnr, function()
    vim.opt_local.statuscolumn = require('user.customizations').lsp_statuscolumn
  end)

  -- if client:supports_method("textDocument/formatting") then
  --   vim.api.nvim_create_autocmd("BufWritePre", {
  --     buffer = bufnr,
  --     callback = function()
  --       vim.lsp.buf.format({ async = false, id = client.id })
  --     end
  --   })
  -- end
  if client:supports_method('textDocument/foldingRange') then
    local win = vim.api.nvim_get_current_win()
    vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
  end
end

return M

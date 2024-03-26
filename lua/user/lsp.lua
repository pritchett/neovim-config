local M = {}

vim.lsp.handlers['textDocument/codeAction'] = require 'lsputil.codeAction'.code_action_handler
-- vim.lsp.handlers['textDocument/references'] = require'lsputil.locations'.references_handler
vim.lsp.handlers['textDocument/definition'] = require 'lsputil.locations'.definition_handler
vim.lsp.handlers['textDocument/declaration'] = require 'lsputil.locations'.declaration_handler
vim.lsp.handlers['textDocument/typeDefinition'] = require 'lsputil.locations'.typeDefinition_handler
vim.lsp.handlers['textDocument/implementation'] = require 'lsputil.locations'.implementation_handler
vim.lsp.handlers['textDocument/documentSymbol'] = vim.lsp.with(require 'lsputil.symbols'.document_handler, {
  border = "rounded"
})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers["textDocument/signatureHelp"], {
  border = "rounded"
})
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})
vim.lsp.handlers['workspace/symbol'] = require 'lsputil.symbols'.workspace_handler

function M.set_keymaps(client, bufnr)
  bufnr = bufnr or 0
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true, buffer = bufnr }
  local function with_defaults(new_opts) return vim.tbl_extend("error", opts, new_opts) end
  keymap('n', '<leader>lcl', vim.lsp.codelens.run, with_defaults({ desc = "Run Code Lens" }))
  keymap('n', 'K', vim.lsp.buf.hover, with_defaults({ desc = "Show Type Information" }))
  keymap('n', 'gK', vim.lsp.buf.signature_help, with_defaults({ desc = "Show Signature Help" }))
  keymap('n', 'gd', '<CMD>lua vim.lsp.buf.definition()<CR>zz', with_defaults({ desc = "Go To Definition" }))
  keymap('n', 'gD', '<CMD>lua vim.lsp.buf.declaration()<CR>zz', with_defaults({ desc = "Go To Declaration" }))

  -- keymap(bufnr, 'n', '<C-G>i', '<CMD>lua vim.lsp.buf.implementation()<CR>zz', opts)
  keymap('n', 'gI', '<CMD>Telescope lsp_implementations theme=ivy<CR>zz',
    with_defaults({ desc = "Go To Implementation" }))
  keymap('n', 'gr', '<CMD>lua vim.lsp.buf.references()<CR>zz', with_defaults({ desc = "Show References" }))
  keymap('n', '<leader>lca', vim.lsp.buf.code_action, with_defaults({ desc = "Run Code Action" }))
  keymap('n', '<Leader>ls', '<CMD>Telescope lsp_dynamic_workspace_symbols theme=ivy<CR>',
    with_defaults({ desc = "Search Workspace Symbols" }))
  keymap('n', '<Leader>lr', vim.lsp.buf.rename, with_defaults({ desc = "Rename Symbol" }))
  -- keymap('n', '<leader><space>', vim.lsp.buf.code_action, opts)
  keymap('n', '<leader>ld',
    function() vim.diagnostic.open_float({ border = "rounded" }, { focus = false, scope = "cursor" }) end,
    with_defaults({ desc = "Show Diagnostics" }))
  keymap('n', '<leader>cs', function()
    vim.diagnostic.setqflist({ open = false, severity = vim.diagnostic.severity.ERROR })
    vim.api.nvim_command('botright cwindow')
  end, with_defaults({ desc = "Open Diagnostics" }))
  keymap('n', '<F9>', function() vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR }) end,
    with_defaults({ desc = "Populate quickfix with project wide compilation errors" }))
  -- keymap(bufnr, 'n', '[I', ':lua require("user.lsp").intercept("[I")<cr>', opts)
  --keymap(bufnr, 'n', '<leader>cs', ':lua vim.diagnostic.setqflist({open = false}); vim.api.nvim_command(\'botright cwindow\')<CR>', opts)
  if client.server_capabilities.selectionRangeProvider then
    keymap('n', '<leader>v', require('lsp-selection-range').trigger, with_defaults({ desc = "LSP Selection" }))
    keymap('v', '<leader>v', require('lsp-selection-range').expand, with_defaults({ desc = "Expand selection" }))
  end
end

function M.on_attach(client, bufnr)
  bufnr = bufnr or 0

  local setlocal = vim.opt_local
  setlocal.foldmethod = 'expr'
  setlocal.foldexpr = 'nvim_treesitter#foldexpr()'

  M.set_keymaps(client, bufnr)

  local refresh_code_lens = function()
    -- local capabilities = client.server_capabilities
    -- if vim.lsp.protocol.resolve_capabilities(capabilities).code_lens then
    if client.server_capabilities.code_lens or client.server_capabilities.codeLensProvider then
      vim.lsp.codelens.refresh()
    end
  end

  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    buffer = bufnr,
    callback = refresh_code_lens,
    group = lsp_id
  })

  require "lsp_signature".on_attach({
    bind = true,
    handler_opts = {
      border = "rounded"
    }
  }, bufnr)

  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format({ async = false, id = client.id })
    end,
    group = lsp_id
  })

  vim.cmd [[TSEnable highlight]]
end

return M

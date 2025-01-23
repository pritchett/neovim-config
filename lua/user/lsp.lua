local M = {}

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers["textDocument/signatureHelp"], {
  border = "rounded"
})
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  title = "Hover"
})

function M.set_keymaps(client, bufnr)
  bufnr = bufnr or 0
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true, buffer = bufnr }
  local function with_defaults(new_opts) return vim.tbl_extend("error", opts, new_opts) end
  keymap('i', '<C-S>', vim.lsp.buf.signature_help, with_defaults({ desc = "Show Signature Help" }))
  -- keymap('n', 'gK', vim.lsp.buf.signature_help, with_defaults({ desc = "Show Signature Help" }))
  keymap('n', 'grr', '<CMD>lua vim.lsp.buf.references()<CR>zz', with_defaults({ desc = "Show References" }))
  -- keymap('n', '<leader>lca', vim.lsp.buf.code_action, with_defaults({ desc = "Run Code Action" }))
  keymap('n', 'gra', vim.lsp.buf.code_action, with_defaults({ desc = "Run Code Action" }))
  keymap('n', 'grn', vim.lsp.buf.rename, with_defaults({ desc = "Rename Symbol" }))
  -- keymap('n', '<Leader>lr', vim.lsp.buf.rename, with_defaults({ desc = "Rename Symbol" }))
  keymap('n', 'gri', function() require('fzf-lua').lsp_implementations({ jump_to_single_result = true }) end,
    with_defaults({ desc = "Implementations" }))
  keymap('n', 'grl', vim.lsp.codelens.run, with_defaults({ desc = "Run Code Lens" }))

  -- keymap('n', 'gO', '<CMD>Telescope lsp_document_symbols theme=ivy<CR>', with_defaults({ desc = "Document Symbols" }))
  keymap('n', 'gO', function() require('fzf-lua').lsp_document_symbols() end,
    with_defaults({ desc = "Document Symbols" }))

  keymap('n', '<leader>lcl', vim.lsp.codelens.run, with_defaults({ desc = "Run Code Lens" }))
  keymap('n', 'gd', '<CMD>lua vim.lsp.buf.definition()<CR>zz', with_defaults({ desc = "Go To Definition" }))
  keymap('n', 'gD', '<CMD>lua vim.lsp.buf.declaration()<CR>zz', with_defaults({ desc = "Go To Declaration" }))

  -----
  keymap('n', 'gI', function()
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then
      local themes = require("telescope.themes")
      telescope.builtin.lsp_implementations(themes.get_ivy())
    else
      local fzf = require("fzf-lua")
      fzf.lsp_implementations()
    end
  end, with_defaults({ desc = "Go To Implementation" }))
  -- keymap('n', 'gI', '<CMD>Telescope lsp_implementations theme=ivy<CR>zz',
  --   with_defaults({ desc = "Go To Implementation" }))
  keymap('n', '<Leader>ls', '<CMD>FzfLua lsp_live_workspace_symbols<CR>',
    with_defaults({ desc = "Search Workspace Symbols" }))
  -- keymap('n', '<Leader>ls', '<CMD>Telescope lsp_dynamic_workspace_symbols theme=ivy<CR>',
  --   with_defaults({ desc = "Search Workspace Symbols" }))
  keymap('n', '<leader>ld',
    function() vim.diagnostic.open_float({ border = "rounded" }, { focus = false, scope = "cursor" }) end,
    with_defaults({ desc = "Show Diagnostics" }))
  keymap('n', '<leader>cs', function()
    vim.diagnostic.setqflist({ open = false, severity = vim.diagnostic.severity.ERROR })
    vim.api.nvim_command('botright cwindow')
  end, with_defaults({ desc = "Open Diagnostics" }))
  -- keymap('n', '<F9>', function() vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR }) end,
  -- with_defaults({ desc = "Populate quickfix with project wide compilation errors" }))
  -- keymap(bufnr, 'n', '[I', ':lua require("user.lsp").intercept("[I")<cr>', opts)
  --keymap(bufnr, 'n', '<leader>cs', ':lua vim.diagnostic.setqflist({open = false}); vim.api.nvim_command(\'botright cwindow\')<CR>', opts)
  if client.server_capabilities.selectionRangeProvider then
    keymap('n', '<leader>v', require('lsp-selection-range').trigger, with_defaults({ desc = "LSP Selection" }))
    keymap('v', '<leader>v', require('lsp-selection-range').expand, with_defaults({ desc = "Expand selection" }))
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

  local setlocal = vim.opt_local
  setlocal.foldmethod = 'expr'
  setlocal.foldexpr = 'nvim_treesitter#foldexpr()'

  if client.server_capabilities.completionProvider then
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
  end
  if client.server_capabilities.definitionProvider then
    vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
  end

  M.set_keymaps(client, bufnr)

  local refresh_code_lens = function()
    -- local capabilities = client.server_capabilities
    -- if vim.lsp.protocol.resolve_capabilities(capabilities).code_lens then
    if client.server_capabilities.code_lens or client.server_capabilities.codeLensProvider then
      pcall(vim.lsp.codelens.refresh)
    end
  end

  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    buffer = bufnr,
    callback = refresh_code_lens,
    group = lsp_id
  })

  -- require "lsp_signature".on_attach({
  --   bind = true,
  --   handler_opts = {
  --     border = "rounded"
  --   }
  -- }, bufnr)

  vim.api.nvim_buf_call(bufnr, function()
    vim.opt_local.statuscolumn = require('user.customizations').lsp_statuscolumn
  end)

  function set_up_autoformatting()
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        if vim.g.skip_autofmt then
          return
        end
        if vim.bo.filetype == "scala" or vim.bo.filetype == "sbt" then
          vim.api.nvim_create_autocmd("BufWritePost", {
            buffer = bufnr,
            once = true,
            callback = function()
              vim.lsp.buf.format({ async = true, id = client.id })
              vim.fn.timer_start(1000, function(_)
                vim.cmd.update()
              end)
            end,
            group = lsp_id
          })
        else
          vim.lsp.buf.format({ async = false, id = client.id })
        end
      end,
      group = lsp_id
    })
  end

  if client.supports_method("textDocument/formatting") then
    set_up_autoformatting()
  end

  vim.cmd [[TSEnable highlight]]
end

return M

local M = {}

function M.set_keymaps(client, bufnr)
  bufnr = bufnr or 0
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true, buffer = bufnr }
  local function with_defaults(new_opts) return vim.tbl_extend("error", opts, new_opts) end
  keymap('n', 'gO', function() require('fzf-lua').lsp_document_symbols() end, { desc = "Document Symbols" })
  keymap('n', 'grl', vim.lsp.codelens.run, { desc = "Run Code Lens" })
  -- keymap('n', 'gd', '<CMD>lua vim.lsp.buf.definition()<CR>zz', with_defaults({ desc = "Go To Definition" }))
  -- keymap('n', 'gD', '<CMD>lua vim.lsp.buf.declaration()<CR>zz', with_defaults({ desc = "Go To Declaration" }))

  -----
  -- keymap('n', 'gI', function()
  --   local ok, telescope = pcall(require, "telescope.builtin")
  --   if ok then
  --     local themes = require("telescope.themes")
  --     telescope.builtin.lsp_implementations(themes.get_ivy())
  --   else
  --     local fzf = require("fzf-lua")
  --     fzf.lsp_implementations()
  --   end
  -- end, with_defaults({ desc = "Go To Implementation" }))
  -- keymap('n', 'gI', '<CMD>Telescope lsp_implementations theme=ivy<CR>zz',
  --   with_defaults({ desc = "Go To Implementation" }))
  vim.keymap.set('n', '<Leader>ls', '<CMD>FzfLua lsp_live_workspace_symbols<CR>', { desc = "Search Workspace Symbols" })
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

  vim.api.nvim_buf_call(bufnr, function()
    vim.opt_local.statuscolumn = require('user.customizations').lsp_statuscolumn
  end)

  local set_up_autoformatting = function()
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

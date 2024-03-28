local ht = require('haskell-tools')
local bufnr = vim.api.nvim_get_current_buf()
local def_opts = { noremap = true, silent = true, buffer = bufnr, }
local i_def_opts = vim.tbl_extend("keep", { expr = true }, def_opts)

-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
-- vim.keymap.set('n', '<space>ca', vim.lsp.codelens.run, opts)
-- Hoogle search for the type signature of the definition under the cursor
vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, def_opts)
-- Evaluate all code snippets
vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all, def_opts)
-- Toggle a GHCi repl for the current package
vim.keymap.set('n', '<leader>rr', ht.repl.toggle, def_opts)
-- Toggle a GHCi repl for the current buffer
vim.keymap.set('n', '<leader>rf', function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, def_opts)
vim.keymap.set('n', '<leader>rq', ht.repl.quit, def_opts)

-- vim.keymap.set('n', '<leader>r', ht.repl.toggle, def_opts)
vim.wo.number = true

vim.keymap.set('n', '<Leader><Space>', vim.lsp.codelens.run, def_opts)

local with_spaces = function(code)
  return function()
    local line = vim.fn.line('.')
    local col = vim.fn.col('.')
    if not line or not col then return end

    -- if (col == 1) then return " " .. code .. " " end

    local first_space
    if (col == 1) then
      first_space = { '' }
    else
      first_space = vim.api.nvim_buf_get_text(0, line - 1, col - 2, line - 1, col - 1, {})
    end

    local second_space = vim.api.nvim_buf_get_text(0, line - 1, col - 1, line - 1, col, {})

    local ret = code
    if (first_space[1] ~= ' ') then
      ret = ' ' .. ret
    end

    if (second_space[1] ~= ' ') then
      ret = ret .. ' '
    end

    return ret
  end
end

vim.keymap.set('n', 'g(', '?^import<CR><CMD>keepjumps norm }<CR><CMD>nohlsearch<CR>', def_opts)
vim.keymap.set('i', '<C-.>', with_spaces('->'), i_def_opts)
vim.keymap.set('i', '<C-,>', with_spaces('<-'), i_def_opts)
vim.keymap.set('i', '<C-4>', with_spaces('<$>'), i_def_opts)
vim.keymap.set('i', '<C-8>', with_spaces('<*>'), i_def_opts)
vim.keymap.set('i', '<C-=>', with_spaces('>>='), i_def_opts)
vim.keymap.set('i', '<C-;>', with_spaces('::'), i_def_opts)
vim.keymap.set('i', '<C-\\>', with_spaces('<|>'), i_def_opts)


-- vim.bo.indentexpr = function()
--   -- local lnum = vim.fn.line('.')
--   local lnum = vim.v.lnum
--   if (lnum == 0) then
--     return -1
--   end
--
--   local ends_with_do = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum -1, false):match("do$")
--   if (ends_with_do) then
--     return 2
--   end
--
--   return -1
-- end

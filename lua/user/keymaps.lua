local opts = { noremap = true, silent = true }

local keymap = vim.api.nvim_set_keymap

local g = vim.g

g.mapleader = ' '
g.localmapleader = ' '

keymap('n', ']c', ':silent cnext<CR>', opts)
keymap('n', '[c', ':silent cprevious<CR>', opts)

keymap('n', '<Leader>bb', ':Telescope buffers theme=ivy<CR>', opts)
keymap('n', '<leader>dr', ":lua require'dap'.repl.open()<CR>", opts)
keymap('n', '<leader>g', "<cmd>Neogit<cr>", opts)
keymap('n', '<leader>e', "<cmd>Neotree toggle<cr>", opts)
keymap('n', '<C-]>', "<C-]>zz", opts)
keymap('n', '<C-W>m', "<C-W>_<C-W>|", opts)

vim.keymap.set('n', '<leader>L', function() require('logger').toggle_log() end)
vim.keymap.set('n', ']f', '<CMD>TSTextobjectGotoNextStart @function.outer<CR>')
vim.keymap.set('n', ']]f', '<CMD>TSTextobjectGotoNextStart @function.inner<CR>')
vim.keymap.set('n', '[f', '<CMD>TSTextobjectGotoPreviousStart @function.outer<CR>')
vim.keymap.set('n', '[[f', '<CMD>TSTextobjectGotoPreviousStart @function.inner<CR>')

vim.keymap.set('n', ']a', '<CMD>TSTextobjectGotoNextStart @parameter.inner<CR>')
vim.keymap.set('n', ']]a', '<CMD>TSTextobjectGotoNextStart @parameter.outer<CR>')
vim.keymap.set('n', '[a', '<CMD>TSTextobjectGotoPreviousStart @parameter.inner<CR>')
vim.keymap.set('n', '[[a', '<CMD>TSTextobjectGotoPreviousStart @parameter.outer<CR>')

-- vim.keymap.set('n', 'gx', function()
--   local word = vim.fn.expand('<cWORD>')
--   local command = {"/usr/bin/open", word}
--   vim.fn.system(command)
-- end)

-- Neorg
vim.keymap.set('n', '<Leader>oc', '<CMD>Neorg capture<CR>', { silent = true })
vim.keymap.set('n', '<Leader>ot', '<CMD>Neorg toggle-concealer<CR>')
vim.keymap.set('n', '<a-TAB>', 'gt')
vim.keymap.set('n', '<a-S-TAB>', 'gT')

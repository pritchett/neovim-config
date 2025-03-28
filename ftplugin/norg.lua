vim.keymap.set('n', 'gO', '<CMD>Neorg toc<CR>', { buffer = true })
vim.keymap.set('n', '<Leader>ot', '<CMD>Neorg toggle-concealer<CR>', { buffer = true, desc = "Toggle concealer" })

vim.keymap.set('n', ']]', function() vim.cmd([[ call search("^\\s*\\*") ]]) end)
vim.keymap.set('n', '[[', function() vim.cmd([[ call search("^\\s*\\*", "b") ]]) end)

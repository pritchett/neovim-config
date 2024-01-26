vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { buffer = true })
vim.keymap.set('n', '<leader>m', '<CMD>Telescope metals commands theme=ivy<CR>', { buffer = true } )
vim.keymap.set('n', '<leader>s', function() require('sbt'):toggle() end, { buffer = true })

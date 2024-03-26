local dap = require('dap')
vim.keymap.set('n', '<F5>', dap.continue, { buffer = true })
vim.keymap.set('n', '<leader>m', '<CMD>Telescope metals commands theme=ivy<CR>', { buffer = true } )

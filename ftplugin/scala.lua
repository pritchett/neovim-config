-- local dap = require('dap')
-- vim.keymap.set('n', '<F5>', dap.continue, { buffer = true })
local ok, _ = pcall(require, 'telescope')
if ok then
  vim.keymap.set('n', '<leader>m', '<CMD>Telescope metals commands theme=ivy<CR>', { buffer = true })
else
  vim.keymap.set('n', '<leader>m', require('metals').commands, { buffer = true, desc = "Metals commands" })
end

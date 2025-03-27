-- Filetypes
require("user.autocmd.dap-float")
require("user.autocmd.scala")
require("user.autocmd.terminal")
require("user.autocmd.debug")
require("user.autocmd.lsp")

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local focus_lost_group = vim.api.nvim_create_augroup('focus', { clear = true })

vim.api.nvim_create_autocmd('FocusLost', {
  desc = 'Write shared data on focus lost',
  group = focus_lost_group,
  callback = function()
    vim.cmd.wshada()
  end
})

vim.api.nvim_create_autocmd('FocusGained', {
  desc = 'Read shared data on focus gained',
  group = focus_lost_group,
  callback = vim.schedule_wrap(function()
    vim.cmd.sleep("100m")
    vim.cmd.rshada()
  end)
})

-- Filetypes
require("user.autocmd.dap-float")
require("user.autocmd.scala")
require("user.autocmd.terminal")
require("user.autocmd.debug")
require("user.autocmd.lsp")

local gid = vim.api.nvim_create_augroup("tabs", {})
vim.api.nvim_create_autocmd("TabEnter", {
  callback = function()
    vim.g.second_last_tab = vim.g.last_tab
    vim.g.last_tab = vim.api.nvim_get_current_tabpage()
  end,
  group = gid
})

local table_contains = function(tbl, elem)
  for _, value in pairs(tbl) do
    if (value == elem) then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd("TabClosed", {
  callback = function()
    if (vim.g.second_last_tab and table_contains(vim.api.nvim_list_tabpages(), vim.g.second_last_tab)) then
      vim.api.nvim_set_current_tabpage(vim.g.second_last_tab)
    end
  end,
  group = gid
})

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

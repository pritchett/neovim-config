-- Filetypes
require("user.autocmd.scala")
require("user.autocmd.lua")
require("user.autocmd.qf")
require("user.autocmd.terminal")
require("user.autocmd.debug")
require("user.autocmd.haskell")
require("user.autocmd.lsp")

local gid = vim.api.nvim_create_augroup("tabs", {})
vim.api.nvim_create_autocmd("TabEnter", {
  callback = function()
    vim.g.second_last_tab = vim.g.last_tab
    vim.g.last_tab = vim.api.nvim_get_current_tabpage()
  end,
  group = gid
})

vim.api.nvim_create_autocmd("TabClosed", {
  callback = function()
    if(vim.g.second_last_tab) then
      vim.api.nvim_set_current_tabpage(vim.g.second_last_tab)
    end
  end,
  group = gid
})


-- Filetypes
require("user.autocmd.scala")
require("user.autocmd.lua")
require("user.autocmd.qf")
require("user.autocmd.terminal")
require("user.autocmd.debug")
require("user.autocmd.haskell")

-- require("user.autocmd.deploy")

local gid = vim.api.nvim_create_augroup("tabs", { clear = true})
vim.api.nvim_create_autocmd("TabClosed", {
  callback = function()
    local tab = vim.fn.tabpagenr()
    if(tab > 1) then
      vim.cmd('tabprevious')
    end
  end,
  group = gid
})


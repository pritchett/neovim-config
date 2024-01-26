-- local execute = vim.api.nvim_command

local gid = vim.api.nvim_create_augroup("terminal", {})

vim.api.nvim_create_autocmd("TermOpen", {
  pattern =  "*",
  callback = function()
    vim.o.number = false
    vim.cmd([[startinsert!]])
  end,
  group = gid
})
--
-- execute [[augroup terminal]]
-- execute [[autocmd!]]
-- execute [[autocmd TermOpen * set nonumber]]
-- execute [[autocmd TermOpen * startinsert]]
-- execute [[autocmd TermClose * if !v:event.status | let buf = expand('<abuf>') | bprevious | exe 'bdelete! '..buf | endif]]
-- execute [[augroup END]]

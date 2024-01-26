-- local execute = vim.api.nvim_command

local gid = vim.api.nvim_create_augroup("debug", {})

vim.api.nvim_create_autocmd("FileType", {
  pattern =  "dap-repl",
  callback = function()
    vim.o.number = false
  end,
  group = gid
})

-- execute [[augroup debug]]
-- execute [[autocmd!]]
-- execute [[autocmd FileType dap-repl set nonumber]]
-- execute [[augroup end]]

local gid = vim.api.nvim_create_augroup("lua", {})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function() vim.o.number = true end,
  group = gid
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern =  "lua",
  callback = vim.schedule_wrap(function()
    vim.lsp.buf.format()
    vim.cmd.update()
  end),
  group = gid
})

local gid = vim.api.nvim_create_augroup("haskell", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.hs",
  callback = vim.schedule_wrap(function()
    vim.lsp.buf.format()
    vim.cmd.update()
  end),
  group = gid
})

-- Skips running the query with dadbod ui when using :wall
if vim.b.db ~= nil then
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = 0,
    callback = function(_)
      local cmd = vim.fn.histget('c', -1)
      if (cmd == "wa" or cmd == "wal" or cmd == "wall") then
        return
      else
        vim.cmd.write()
        vim.cmd.doautocmd('BufWritePost')
      end
    end
  })
end

local gid = vim.api.nvim_create_augroup("dap-float", {})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "dap-float",
  callback = function(args)
    vim.keymap.set("n", "q", "<CMD>close<CR>", { buffer = true })
  end,
  group = gid
})

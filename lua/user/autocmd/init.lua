-- Filetypes
require("user.autocmd.dap-float")
require("user.autocmd.scala")
require("user.autocmd.terminal")
require("user.autocmd.debug")
require("user.autocmd.lsp")

vim.api.nvim_create_autocmd('FileType', {
  desc = "Install treesitter parser",
  group = vim.api.nvim_create_augroup('treesitter-install', { clear = true }),
  callback = function(args)
    local ok, ts = pcall(require, "nvim-treesitter")
    if ok then
      if vim.list_contains(ts.get_installed(), args.match) then
        if (args.match ~= "sql") then
          vim.treesitter.start()
        end
      elseif vim.list_contains(ts.get_available(), args.match) then
        vim.notify("Installing treesitter parser for " .. args.match, vim.log.levels.INFO)
        ts.install(args.match):wait() -- TODO: get rid of :wait
        vim.treesitter.start()
      end
    end
  end
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = vim.hl.on_yank,
})

-- local focus_group = vim.api.nvim_create_augroup('focus', { clear = true })

-- vim.api.nvim_create_autocmd('FocusLost', {
--   desc = 'Write shared data on focus lost',
--   group = focus_group,
--   callback = function()
--     vim.cmd.wshada()
--   end
-- })
--
-- vim.api.nvim_create_autocmd('FocusGained', {
--   desc = 'Read shared data on focus gained',
--   group = focus_group,
--   callback = vim.schedule_wrap(function()
--     vim.cmd.sleep("100m")
--     vim.cmd.rshada()
--   end)
-- })

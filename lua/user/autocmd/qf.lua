-- local execute = vim.api.nvim_command

-- execute [[augroup qf]]
-- execute [[autocmd!]]
-- execute [[autocmd FileType qf wincmd J]]
-- execute [[augroup end]]
--
local gid = vim.api.nvim_create_augroup("qf", {})
-- local last_win

-- vim.api.nvim_create_autocmd("WinLeave", {
--   callback = function(args)
--     end, 
--   group = gid
-- })

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern =  "qf",
--   callback = function(args)
--     vim.cmd("wincmd J")
--   end,
--   group = gid
-- })


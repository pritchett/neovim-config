require("user.options")
require("user.plugins")
require("user.keymaps")
require("user.colorscheme")
require("user.autocmd")
require("user.commands")


vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
})

-- local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
local signs = { Error = "❌", Warn = "❕", Hint = "❔", Info = "ℹ︎" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = 'SignColumn', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '🟡', texthl = 'SignColumn', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '🚫', texthl = 'SignColumn', linehl = '', numhl = '' })
-- vim.fn.sign_define('DapStopped', { text = '➡️', texthl = 'SignColumn', linehl = 'DebugBreakpointLine', numhl = '' })
-- vim.fn.sign_define('DapStopped', { text = '▶️', texthl = 'SignColumn', linehl = 'DebugBreakpointLine', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '👉', texthl = 'SignColumn', linehl = 'DebugBreakpointLine', numhl = '' })


vim.cmd.packadd("cfilter")

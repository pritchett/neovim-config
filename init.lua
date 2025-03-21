require("user.options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- highlight-end
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "catppuccin-macchiato" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
  dev = {
    path = "~/Development/",
    -- patterns = { "pritchett", "NeogitOrg" }
    -- patterns = { "pritchett" }
  },
  diff = {
    cmd = "diffview.nvim"
  },
  ui = {
    border = "rounded"
  }
})

require("user.keymaps")
require("user.autocmd")
require("user.commands")
vim.opt_local.statuscolumn = require('user.customizations').lsp_statuscolumn

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
  virtual_lines = true
})

-- local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
local signs = { Error = "❌", Warn = "❕", Hint = "❔", Info = "ℹ︎" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local sign = vim.fn.sign_define
sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })


-- vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = 'SignColumn', linehl = '', numhl = '' })
-- vim.fn.sign_define('DapBreakpointCondition', { text = '🟡', texthl = 'SignColumn', linehl = '', numhl = '' })
-- vim.fn.sign_define('DapBreakpointRejected', { text = '🚫', texthl = 'SignColumn', linehl = '', numhl = '' })
-- vim.fn.sign_define('DapStopped', { text = '➡️', texthl = 'SignColumn', linehl = 'DebugBreakpointLine', numhl = '' })
-- vim.fn.sign_define('DapStopped', { text = '▶️', texthl = 'SignColumn', linehl = 'DebugBreakpointLine', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '👉', texthl = 'SignColumn', linehl = 'DebugBreakpointLine', numhl = '' })

vim.cmd.packadd("cfilter")

vim.g.db_ui_foreign_table_overrides = { ["mysql://root@127.0.0.1:3306/"] = { travel_booking_id = { "TRAVEL_BOOKING", "id", "book" } } }

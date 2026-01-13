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
  checker = { enabled = true, notify = true },
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
require("user.filetype")
require("filetype")
-- vim.opt_local.statuscolumn = require('user.customizations').lsp_statuscolumn

vim.diagnostic.config({
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_lines = false
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
vim.cmd.packadd("nohlsearch")

vim.keymap.set({ 'x', 'o' }, 'iu', function()
  local linenr = vim.fn.line('.')
  local line = vim.fn.getline(linenr)
  local pattern = "[a-z0-9]\\{8\\}-[a-z0-9]\\{4\\}-[a-z0-9]\\{4\\}-[a-z0-9]\\{4\\}-[a-z0-9]\\{12\\}"
  local cur_pos = vim.fn.getcurpos()[3]
  local results = vim.fn.matchstrpos(line, pattern)
  while results[1] ~= "" do
    if (cur_pos >= results[2] and cur_pos <= results[3]) then
      vim.fn.setpos("'<", { 0, linenr, results[2] + 1, 0 })
      vim.fn.setpos("'>", { 0, linenr, results[3], 0 })
      vim.cmd.normal({ args = { "gv" }, bang = true })
      -- vim.cmd.normal({ args = { results[2] + 1 .. "|v" .. results[3] .. "|" }, bang = true })
      return
    end
    results = vim.fn.matchstrpos(line, pattern, results[3])
  end
end, { desc = "Inner UUID" })


-- vim.filetype.add({
--   extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
--   filename = {
--     ["vifmrc"] = "vim",
--     [".gitlab-ci.yml"] = "yaml.gitlab"
--   },
--   pattern = {
--     [".*/waybar/config"] = "jsonc",
--     [".*/mako/config"] = "dosini",
--     [".*/kitty/.+%.conf"] = "kitty",
--     [".*/hypr/.+%.conf"] = "hyprlang",
--     ["%.env%.[%w_.-]+"] = "sh",
--   },
-- })


vim.treesitter.language.register("bash", "kitty")

vim.lsp.enable({ 'gitlab-ci-ls', 'bashls', 'yamlls', 'lua_ls', 'purescript-language-server', 'fennel-ls' })
-- vim.api.nvim_create_autocmd('LspProgress', {
--   callback = function(ev)
--     local value = ev.data.params.value
--     if value.kind == 'begin' then
--       vim.api.nvim_ui_send('\027]9;4;1;0\027\\')
--     elseif value.kind == 'end' then
--       vim.api.nvim_ui_send('\027]9;4;0\027\\')
--     elseif value.kind == 'report' then
--       vim.api.nvim_ui_send(string.format('\027]9;4;1;%d\027\\', value.percentage or 0))
--     end
--   end,
-- })

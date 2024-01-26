require("user.options")
require("user.keymaps")
require("user.plugins")
require("user.colorscheme")
require("user.autocmd")
-- require('aria')

-- Add paths for luarocks installed by `luarocks --lua-version 5.1 install`

package.path = package.path
    .. ";/Users/bpritchett/.luarocks/share/lua/5.1/?.lua;/Users/bpritchett/.luarocks/share/lua/5.1/?/init.lua"
package.cpath = package.cpath .. ";/Users/bpritchett/.luarocks/lib/lua/5.1/?.so"

vim.diagnostic.config({
  virtual_text = false,
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

-- vim.cmd [[ highlight! Refactor guibg=Red ]]
-- vim.cmd [[ highlight! VertSplit guifg=grey ]]

vim.api.nvim_create_user_command("Messages", function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd([[put= execute('messages')]])
  end)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.cmd.split()
  local winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(winnr, bufnr)
end, {})

vim.api.nvim_create_user_command("Config", function(args)
  local tabnr = vim.fn.tabpagenr()
  vim.cmd.tabnew()
  vim.cmd.tcd("~/.config/nvim/")
  if args['args'] == 'plugins' then
    local ok, _ = pcall(vim.cmd.edit, "~/.config/nvim/lua/user/plugins/init.lua")
    if not ok then
      vim.cmd.tabclose()
      vim.cmd.tabnext(tabnr)
    end
  elseif args['args'] == 'keymaps' then
    local ok, _ = pcall(vim.cmd.edit, "~/.config/nvim/lua/user/keymaps.lua")
    if not ok then
      vim.cmd.tabclose()
      vim.cmd.tabnext(tabnr)
    end
  elseif args['args'] == 'autocmds' then
    local ok, _ = pcall(vim.cmd.edit, "~/.config/nvim/lua/user/autocmd/init.lua")
    if not ok then
      vim.cmd.tabclose()
      vim.cmd.tabnext(tabnr)
    end
  else
    local ok, _ = pcall(vim.cmd.edit, "~/.config/nvim/init.lua")
    if not ok then
      vim.cmd.tabclose()
      vim.cmd.tabnext(tabnr)
    end
  end
end, {
  nargs = "?",
  complete = function() return { "plugins", "keymaps", "autocmds" } end
})

vim.api.nvim_create_user_command("UrlDecode", function()
  vim.cmd('!~/Development/scripts/url_decode.py')
end, {
  range = true
})

vim.api.nvim_create_user_command("Dbee", function()
  require('dbee').open()
end, {})

vim.api.nvim_create_user_command("FindFiles", function()
  vim.cmd("Telescope find_files theme=ivy")
end, {})

vim.api.nvim_create_user_command("LiveGrep", function()
  vim.cmd("Telescope live_grep theme=ivy")
end, {})

vim.cmd.packadd("cfilter")

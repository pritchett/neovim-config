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


function get_fold_column()
  local fillchars = vim.opt.fillchars:get()
  local fold_line_before = vim.fn.foldlevel(vim.v.lnum - 1)
  local fold_line_curr = vim.fn.foldlevel(vim.v.lnum)
  local increased_fold = fold_line_curr > fold_line_before
  if increased_fold and vim.fn.foldclosed(vim.v.lnum) == vim.v.lnum then
    return fillchars.foldclose
  elseif increased_fold then
    return fillchars.foldopen
  elseif fold_line_curr > 0 then
    return fillchars.foldsep
  end
  return fillchars.fold
end

function get_signs_minus_gitsigns()
  local line = ""
  for k, ns in pairs(vim.api.nvim_get_namespaces()) do
    if k ~= "gitsigns_signs_" then
      local signs = vim.api.nvim_buf_get_extmarks(0, ns, { vim.v.lnum - 1, 0 }, { vim.v.lnum - 1, -1 }, { type = "sign" })
      for _, sign in ipairs(signs) do
        local sign_id = sign[1]
        local details = vim.api.nvim_buf_get_extmark_by_id(0, ns, sign_id, { details = true })[3]
        if (details and details.sign_hl_group) then
          line = line .. '%#' .. details.sign_hl_group .. '#'
        end
        if (details and details.sign_text) then
          line = line .. details.sign_text
        end
        if line ~= "" then
          return line
        end
      end
    end
  end
  return line
end

function get_gitsigns_sign_column()
  local ns = vim.api.nvim_get_namespaces().gitsigns_signs_
  if not ns then
    return ""
  end
  -- There should only ever be one sign from Gitsigns here
  local gitsigns = vim.api.nvim_buf_get_extmarks(0, ns, { vim.v.lnum - 1, 0 }, { vim.v.lnum - 1, -1 }, { type = "sign" })
  for _, sign in ipairs(gitsigns) do
    local sign_id = sign[1]
    local details = vim.api.nvim_buf_get_extmark_by_id(0, ns, sign_id, { details = true })[3]
    return '%#' .. details.sign_hl_group .. '#' .. details.sign_text
  end
  return ""
end

-- local ns = vim.api.nvim_create_namespace("external_msg_area")
-- vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
--   local content = ...
--   if event == 'msg_showcmd' then
--     return
--     -- local content = ...
--     -- if #content > 0 then
--     --   -- local it = vim.iter(content)
--     --   -- it:map(function(tup) return tup[2] end)
--     --   -- set_showmess(it:join(''))
--     --   vim.schedule(function() vim.notify(vim.inspect(content)) end)
--     -- end
--   end
--
--   vim.schedule(function() vim.notify(vim.inspect(content)) end)
-- end)

vim.api.nvim_create_user_command("Messages", function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd([[put= execute('messages')]])
  end)
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
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
  complete = function(argLead)
    local options = { "plugins", "keymaps", "autocmds" }
    local res = {}
    for _, opt in ipairs(options) do
      if opt:sub(1, argLead:len()) == argLead then
        table.insert(res, opt)
      end
    end

    return res
  end
})

vim.api.nvim_create_user_command("UrlDecode", function()
  vim.cmd('!~/Development/scripts/url_decode.py')
end, {
  range = true
})

vim.api.nvim_create_user_command("UrlEncode", function(args)
  vim.notify(vim.inspect(args))
  if args.args ~= "" then
    local cmd = "execute('!~/Development/scripts/url_encode.py " .. args.args .. "')"
    vim.cmd.echo(cmd)
  else
    vim.cmd(args.line1 .. ',' .. args.line2 .. '!~/Development/scripts/url_encode.py')
  end
end, {
  range = true,
  nargs = '?'
})

vim.api.nvim_create_user_command("FindFiles", function()
  vim.cmd("Telescope find_files theme=ivy")
end, {})

vim.api.nvim_create_user_command("LiveGrep", function()
  vim.cmd("Telescope live_grep theme=ivy")
end, {})

vim.api.nvim_create_user_command('Browse', function(args)
  vim.ui.open(args.fargs[1])
end, { nargs = 1 })

vim.api.nvim_create_user_command('Deployments',
  function(args)
    vim.cmd.split()
    vim.cmd.term("w3m https://deploy.infra.tstllc.net/deploy/")
    vim.cmd.startinsert()
  end, {})

vim.api.nvim_create_user_command('TelescopeResume', function()
  vim.cmd("Telescope resule")
end, {})

vim.api.nvim_create_user_command('ToggleDiagnosticVirtualText', function()
  vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
end, { desc = "Toggle diagnostic virtual text display" })

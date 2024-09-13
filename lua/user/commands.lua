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

local sections = { "main", "plugins", "keymaps", "autocmds", "commands", "options", "project" }
vim.api.nvim_create_user_command("Config", function(args)
  local tabnr = vim.fn.tabpagenr()
  local open_file = function(reset_pwd, file)
    vim.cmd.tabnew()
    if (reset_pwd) then
      vim.cmd.tcd("~/.config/nvim/")
    end
    local ok, _ = pcall(vim.cmd.edit, file)
    if not ok then
      vim.cmd.tabclose()
      vim.cmd.tabnext(tabnr)
    end
  end

  local open_config = function(section)
    if section == 'main' then
      open_file(true, "~/.config/nvim/init.lua")
    elseif section == 'plugins' then
      open_file(true, "~/.config/nvim/lua/user/plugins/init.lua")
    elseif section == 'keymaps' then
      open_file(true, "~/.config/nvim/lua/user/keymaps.lua")
    elseif section == 'autocmds' then
      open_file(true, "~/.config/nvim/lua/user/autocmd/init.lua")
    elseif section == 'commands' then
      open_file(true, "~/.config/nvim/lua/user/commands.lua")
    elseif section == 'options' then
      open_file(true, "~/.config/nvim/lua/user/options.lua")
    elseif section == 'project' then
      open_file(false, vim.fn.getcwd() .. "/.nvim.lua")
    else
      vim.notify("Could not find configuration secion: " .. section, vim.diagnostic.severity.ERROR)
    end
  end

  if args and args['args'] ~= "" then
    local opt = args['args']
    open_config(opt)
  else
    vim.ui.select(sections, { prompt = "Config" },
      function(choice)
        if (not choice or choice == "") then
          return
        end
        open_config(choice)
      end)
  end
end, {
  nargs = "?",
  complete = function(argLead)
    local res = {}
    for _, opt in ipairs(sections) do
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

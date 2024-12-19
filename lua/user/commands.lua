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

vim.api.nvim_create_user_command("Diagnotics", function()
  require('telescope.builtin').diagnostics(require('telescope.themes').get_ivy({
    root_dir = vim.fn.getcwd()
  }))
end, {})

vim.api.nvim_create_user_command("Config", function()
  require('telescope.builtin').find_files(require('telescope.themes').get_ivy(
    {
      -- cwd = vim.fn.stdpath('config'),
      search_dirs = { vim.fn.stdpath('config') },
      -- search_file = vim.fn.getcwd() .. "/.nvim.lua"
    }))
end, {})

vim.api.nvim_create_user_command("TelescopeResume", function()
  require('telescope.builtin').resume({ cache_index = 2 })
end, {})

vim.api.nvim_create_user_command("UrlDecode", function()
  vim.cmd('!~/Development/scripts/url_decode.py')
end, {
  range = true
})

vim.api.nvim_create_user_command("UrlEncode", function(args)
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
  require('telescope.builtin').find_files(require('telescope.themes').get_ivy(
    {
      -- cwd = vim.fn.stdpath('config'),
      -- search_dirs = { vim.fn.stdpath('config') },
      -- search_file = vim.fn.getcwd() .. "/.nvim.lua"
    }))
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

vim.api.nvim_create_user_command('ToggleDiagnosticVirtualText', function()
  vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
end, { desc = "Toggle diagnostic virtual text display" })

vim.api.nvim_create_user_command('Help', function()
  vim.cmd("Telescope help_tags theme=ivy")
end, { desc = "Help tags" })

local Project = require('user.projects')
vim.api.nvim_create_user_command('Projects', function()
  Project.find_projects_async(function(projects)
    local titles = {}
    local ids = {}
    for _, project in ipairs(projects) do
      if (not (project.project_name == vim.g.project_name)) then
        table.insert(titles, project.project_name)
        table.insert(ids, project.window_id)
      end
    end

    local newstart = "Start up a non-running project"
    table.insert(titles, newstart)

    local start_new_project = function()
      vim.system({ 'ls', '/Users/brian/Development' }, { text = true }, function(out)
        local start_projects = {}
        for proj in out.stdout:gmatch("[^\r\n]+") do
          local should_insert = true
          for _, check_project in ipairs(projects) do
            if proj == check_project.project_name then
              should_insert = false
              break
            end
          end
          if should_insert then
            table.insert(start_projects, proj)
          end
        end

        vim.schedule(function()
          vim.ui.select(start_projects, { prompt = "Project Name:" }, function(project)
            if (project and project ~= "") then
              Project.project_remote_start_async(project, true)
            end
          end)
        end)
      end)
    end

    local start_or_switch_project = function(choice, idx)
      if (choice == newstart) then
        vim.schedule(start_new_project)
      elseif (idx) then
        vim.system({ "kitten", "@focus-tab", "--match", "window_id:" .. ids[idx] })
      end
    end

    vim.schedule(function() vim.ui.select(titles, { prompt = "Select project:" }, start_or_switch_project) end)
  end)
end, { desc = "List Projects" })

local M = {}

--- @param project_name string
M.project_start = function(project_name)
   if vim.g.project_name then
      return
   end
   vim.system({ "kitten", "@set-tab-title", project_name })
   vim.system({
      "kitten",
      "@set-user-vars",
      "--match",
      "id:" .. vim.env.KITTY_WINDOW_ID,
      "NVIM_PROJECT_NAME=" .. project_name,
   })
   vim.system({
      "kitten",
      "@set-user-vars",
      "--match",
      "id:" .. vim.env.KITTY_WINDOW_ID,
      "NVIM_SERVER_NAME=" .. vim.v.servername,
   })
   vim.g.project_name = project_name
end

--- @class Project
--- @field project_name string
--- @field server string
--- @field window_id integer
local Project = {}

--- @param cb fun(projects: Project[])
M.find_projects_async = function(cb)
   return vim.system({ "kitten", "@ls" }, { text = true }, function(out)
      local cmd = {
         "jq",
         "[.[] | .tabs[] | .windows[] | select(.user_vars.NVIM_PROJECT_NAME != null) | { window_id: .id, project_name: .user_vars.NVIM_PROJECT_NAME, server: .user_vars.NVIM_SERVER_NAME }]",
      }
      vim.system(cmd, { text = true, stdin = out.stdout }, function(out)
         --- @var projects Project[]
         local projects = vim.json.decode(out.stdout, { luanil = { object = true, array = true } })
         cb(projects)
      end)
   end)
end

--- @param query string a jq query
--- @param cb fun(objs?: table[])
--- @return nil
local query_kitten_ls_with_jq_async = function(query, cb)
   vim.system({ "kitten", "@ls" }, { text = true }, function(data)
      local cmd = { "jq", query }
      vim.system(cmd, { text = true, stdin = data.stdout }, function(out)
         if not out.stdout or out.stdout == "" then
            cb(nil)
         else
            local objs = vim.json.decode(out.stdout, { luanil = { object = true, array = true } })
            cb(objs)
         end
      end)
   end)
end

---@alias Projects.Project { window_id: integer, server: string, project_name: string }
---@alias Projects.FindResultsCallback {found: fun(project: Projects.Project), not_found: fun() }

--- @param project_name string
--- @param cbs Projects.FindResultsCallback
--- @return nil
M.find_project_async = function(project_name, cbs)
   local query = '[.[] | .tabs[] | .windows[] | select(.user_vars.NVIM_PROJECT_NAME == "'
      .. project_name
      .. '") | { window_id: .id, project_name: .user_vars.NVIM_PROJECT_NAME, server: .user_vars.NVIM_SERVER_NAME }] | .[0]'

   query_kitten_ls_with_jq_async(query, function(result)
      if not result then
         cbs.not_found()
      else
         cbs.found(result)
      end
   end)
end

---@param project_name string the name of the project
---@return Projects.Project | nil
M.find_project = function(project_name)
   local needs_return = false
   local results = nil
   M.find_project_async(project_name, {
      found = vim.schedule_wrap(function(projects)
         results = projects
         needs_return = true
      end),
      not_found = vim.schedule_wrap(function()
         needs_return = true
      end),
   })

   while not needs_return do
   end
   return results
end

---@param project_name string
---@param switch boolean if it should switch to the project
---@param cb? fun(project: string) function to run after it starts
M.project_remote_start_async = function(project_name, switch, cb)
   local do_not_switch = "--dont-take-focus"

   local cmd = {
      "kitten",
      "@launch",
      "--type",
      "tab",
      "--cwd",
      "~/Development/" .. project_name,
      "--copy-env",
      "--no-response",
      "--tab-title",
      project_name,
      "--var",
      "NVIM_PROJECT_NAME:" .. project_name,
   }

   if not switch then
      table.insert(cmd, do_not_switch)
   end

   local nvim_cmd = {
      "zsh",
      "-c",
      "nvim",
      "-V1",
      "-c",
      "lua require('user.projects').project_start('" .. project_name .. "')",
      "; zsh -is",
   }
   local nvim_zsh_cmd =
      { "zsh", "-c", [[nvim -V1 -c lua require('user.projects').project_start(']] .. project_name .. [['); zsh -is]] }
   -- for _, ins in ipairs(nvim_cmd) do
   --   table.insert(cmd, ins)
   -- end

   table.insert(cmd, nvim_zsh_cmd)
   -- local interactive_zsh_shell_after_nvim_exits = { ";", "zsh", "-is" }
   -- for _, ins in ipairs(interactive_zsh_shell_after_nvim_exits) do
   --   table.insert(cmd, ins)
   -- end

   local run_if_cb = function(project)
      if cb then
         cb(project)
      end
   end

   local switchfn = function(project)
      local switch_cmd = {
         "kitten",
         "@focus-tab",
         "--match",
         "title:" .. project_name,
      }
      vim.system(switch_cmd, {}, function(out)
         run_if_cb(project)
      end)
   end

   local switch_and_cb = function(project)
      if switch then
         switchfn(project)
      else
         run_if_cb(project)
      end
   end

   local wait_till_running
   wait_till_running = function(times)
      if times < 10000 then
         vim.schedule(function()
            wait_till_running(times + 1)
         end)
      else
         M.find_project_async(project_name, {
            not_found = function()
               vim.schedule(function()
                  wait_till_running(0)
               end)
            end,
            found = run_if_cb,
         })
      end
   end

   M.find_project_async(project_name, {
      not_found = function()
         vim.system(cmd, {}, function(_)
            wait_till_running(0)
         end)
      end,
      found = switch_and_cb,
   })
end

M.project_exec_async = function(project_name, command, cb)
   return M.project_remote_start_async(project_name, false, function(project)
      vim.system({ "nvim", "--server", project.server, "--remote-expr", command })
      if cb then
         cb()
      end
   end)
end

M.project_exec = function(project_name, command)
   return M.project_exec_async(project_name, command)
end

return M

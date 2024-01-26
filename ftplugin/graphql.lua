local log = require('logger').log

local run = function()
  local args = {}
  local vars_mode = false
  local request_mode = false
  for _, line in pairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:find("# URL") then
      args["url"] = string.gsub(line, "^# URL ", "")
      vars_mode = false
      request_mode = false
    end

    if line:find("# TOKEN") then
      args["token"] = string.gsub(line, "^# TOKEN ", "")
      vars_mode = false
      request_mode = false
    end

    if line:find("# VARS") then
      vars_mode = true
      request_mode = false
      args["vars"] = {}
    end

    if line:find("# REQUEST") then
      vars_mode = false
      request_mode = true
      args["request"] = {}
    end

    if vars_mode then
      if not line:find("# VARS") then
        table.insert(args["vars"], line)
      end
    end

    if request_mode then
      if not line:find("# REQUEST") then
        table.insert(args["request"], line)
      end
    end

  end

  local command = { "gq", args["url"], "-H", "Authorization: Bearer " .. args["token"], "-q",
    table.concat(args["request"]) }

  for _, arg in pairs(args["vars"]) do
    table.insert(command, "-v")
    table.insert(command, arg)
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "filetype", "json")

  local handler = function(_, data)
    if not data then return end
    for _, line in ipairs(data) do
      if not line:find("Executing query...") and not line:match("^ done$") and not line:match("^$") then
        vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {line})
      end
    end
  end

  log("graphql command: " .. table.concat(command, " "))

  vim.fn.jobstart(command, {
    buffered_stdout = true,
    buffered_stderr = true,
    on_stdout = handler,
    on_stderr = handler,
    on_exit = function(_, _, _)
      vim.cmd('split')
      local winnr = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(winnr, bufnr)
    end
  })
end

local update_token = function()
  local token = vim.regex("access_token")
  local service_down = vim.regex("<title>503 Service Unavailable</title>")

  local url = function(clientno)
    return clientno
  end

  local client = "7000209"

  local secrets = {
    ["7000206"] = "<redacted>",
    ["7000209"] = "<redacted>",
    ["7000266"] = "<redacted>",
    ["7000239"] = "<redacted>"
  }

  local qa_secrets = {
    ["7000213"] = "<redacted>",
    ["7000317"] = "<redacted>"
  }

  for _, line in pairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:find("# URL") then
      if line:find("qa") then
        url = function(clientno)
          return "https://api.aria51-qa.devfarm.ariasystems.net/apitools/jwt_generator.php?client_no=" .. clientno .. "&client_secret=" .. qa_secrets[clientno] .. "&format=json&expiry=9999"
        end
      else
        url = function(clientno)
          return "https://api.aria51-microservices.devfarm.ariasystems.net/apitools/jwt_generator.php?client_no=" .. clientno .. "&client_secret=" .. secrets[clientno] .. "&format=json&expiry=9999"
        end
      end
    end

    if line:find("# CLIENT") then
      client = string.gsub(line, "^# CLIENT ", "")
    end
  end
  local command = { "curl", "-s", "-k" }
  table.insert(command, url(client))
  vim.fn.jobstart(command, {
    buffered_stdout = true,
    buffered_stderr = true,
    on_stdout = function(_, data)
      if not data then
        return
      end
      for _, line in pairs(data) do
        if service_down and service_down:match_str(line) then
          vim.schedule(function()
            vim.notify("Devfarm is down", "error", {
              title = "Aria Graphql"
            })
          end)
          return
        end
        if token and token:match_str(line) then
          local token_str = string.gsub(line, "%s", "")
          token_str = string.gsub(token_str, '"access_token":', "")
          token_str = string.gsub(token_str, '"', "")
          local file_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          for i, fline in ipairs(file_lines) do
            if fline:find("# TOKEN") then
              vim.api.nvim_buf_set_lines(0, i - 1, i, false, { "# TOKEN " .. token_str })
              vim.schedule(function()
                vim.notify("Updated token", "info", {
                  title = "Aria Graphql"
                })
              end)
            end
          end
        end
      end
    end
  })
end

local introspect = function()
  local args = {}
  for _, line in pairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    if line:find("# URL") then
      args["url"] = string.gsub(line, "^# URL ", "")
    end

    if line:find("# TOKEN") then
      args["token"] = string.gsub(line, "^# TOKEN ", "")
    end
  end

  local command = { "gq", args["url"], "-H", "Authorization: Bearer " .. args["token"], "--introspect" }

  local bufnr = vim.api.nvim_create_buf(false, true)

  local handler = function(_, data)
    if not data then
      return
    end

    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
  end

  vim.fn.jobstart(command, {
    buffered_stdout = true,
    buffered_stderr = true,
    on_stdout = handler,
    on_stderr = handler,
    on_exit = function(_, _, _)
      vim.cmd('split')
      local winnr = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(winnr, bufnr)
    end
  })
end

vim.api.nvim_buf_create_user_command(0, "UpdateToken", update_token, { desc = "Update the Aria token"})
vim.api.nvim_buf_create_user_command(0, "Introspect", introspect, { desc= "Introspect on the graphql server"})
vim.api.nvim_buf_create_user_command(0, "Run", run, { desc = "Execute graphql call"})

vim.keymap.set('n', '<Leader>x', run, { buffer = true, desc = "Execute graphql call" })
vim.keymap.set('n', '<Leader>t', update_token, { buffer = true, desc = "Update Aria token" })
vim.keymap.set('n', '<Leader>i', introspect, { buffer = true, desc = "Run Introspect against graphql server" })


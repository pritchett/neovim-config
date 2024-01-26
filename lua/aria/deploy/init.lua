local log = require('logger').log

local edit_deploy = function(ns)
  vim.cmd("sp .deploy/" .. ns)
end

vim.api.nvim_create_user_command("Deploy", function(args)
  local ns
  if not args['args'] or args['args'] == '' then
    ns = 'bpritchett-apps'
  else
    ns = args['args']
  end

  edit_deploy(ns)
end, {
  desc = "Deploy to aria k8s",
  complete = function() return { 'bpritchett-apps', 'bpritchett-qa-apps' } end,
  nargs = '?'
})

local gid = vim.api.nvim_create_augroup("deploy", {})

local restart_image = function(ns, service)
  local scale_service_down = { "kubectl", "-n", ns, "scale", "--replicas=0", "deployments/" .. service }
  local scale_service_up = { "kubectl", "-n", ns, "scale", "--replicas=1", "deployments/" .. service }
  vim.fn.jobstart(scale_service_down, {
    on_exit = function(job_id, exit_code, event)
      if (exit_code == 0) then
        vim.fn.jobstart(scale_service_up, {
          on_exit = function(job_id, exit_code, event)
            if (exit_code == 0) then
              vim.notify("Restarted " .. service, vim.log.levels.INFO, {
                title = "Aria Deploy"
              })
            else
              vim.notify("Failed to restart " .. service, vim.log.levels.ERROR, {
                title = "Aria Deploy"
              })
            end
          end
        })
      else
        vim.notify("Failed to restart " .. service, vim.log.levels.ERROR, {
          title = "Aria Deploy"
        })
      end
    end
  })
end

local deploy_image = function(ns, hash, service)
  local devel_documents = "/Users/bpritchett/Development/devel-documents/dev1k8s/helm"
  local file_exists = function(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
  end

  local service_helm_chart_file = devel_documents .. "/" .. ns .. "/" .. service .. "-values.yaml"
  local service_helm_chart_command = {}
  if file_exists(service_helm_chart_file) then
    service_helm_chart_command = { "-f", service_helm_chart_file }
  end

  local command = { "helm", "upgrade", service, "dev1k8s/" .. service, "--version", "7.50.0-SNAPSHOT", "--namespace", ns,
    "--install", "-f", devel_documents .. "/cluster-values.yaml", "-f",
    devel_documents .. "/" .. ns .. "/env-values.yaml" }
  for _, part in pairs(service_helm_chart_command) do
    table.insert(command, part)
  end

  table.insert(command, "--set")
  table.insert(command, "'image.tag=" .. hash .. "'")

  vim.fn.jobstart(command, {
    buffered_stdout = true,
    buffered_stderr = true,
    on_stderr = function(_, data)
      if data then
        log("std err" .. vim.inspect(data))
      end
    end,
    on_exit = function(job_id, exit_code, event)
      if (exit_code == 0) then
        vim.schedule(function()
          vim.notify("Deployed " .. service, "info", {
            title = "Aria Deploy"
          })
        end)
      else
        vim.schedule(function()
          vim.notify("Failed to deploy " .. service, "error", {
            title = "Aria Deploy"
          })
        end)
      end
    end
  })
end

local get_deployment_json = function(ns, service, cb)
  local get_deployed_version_command = { "kubectl", "-n", ns, "get", "deployments", service, "-o", "json" }
  local json_str = ""
  vim.fn.jobstart(get_deployed_version_command, {
    buffered_stdout = true,
    buffered_stderr = true,
    on_stdout = function(chan_id, data, name)
      if data then
        json_str = json_str .. table.concat(data)
      end
    end,
    on_stderr = function(chan_id, data, name)
      if data then
        log(vim.inspect(data))
      end
    end,
    on_exit = function() cb(json_str) end
  })
end

local compilation_failed = vim.regex("Compilation failed")
local docker_not_running = vim.regex("Cannot connect to the Docker daemon")
local not_on_vpn = vim.regex("Get \"https://harbor.dev1k8s.us-east-1.ariasystems.net/v2/\": Service Unavailable\\|context deadline exceeded")
local possible_internet_down = vim.regex("lookup auth.docker.io: no such host")
local nonzero_error = vim.regex("Nonzero exit value")
local other_error = vim.regex("stack trace is suppressed; run last .*Service / Docker / publish for the full output")
local published = function(deployment)
  return vim.regex("Published image harbor.dev1k8s.us-east-1.ariasystems.net/library/" .. deployment .. ".*[^:latest]")
end

local deploy = function(ns)
  local deployment
  local ok, file = pcall(vim.fn.readfile, "project/target/active.json")
  if not ok then
    log("SBT is not running")
    vim.schedule(function()
      vim.notify("SBT is not running", "error", {
        title = "Aria Deploy"
      })
    end)
    return
  end
  local uri = vim.fn.json_decode(file[1]).uri:gsub("^local://", "")
  local talk_to_sbt = { "nc", "-U", "-w", "120", uri }
  local chan_id = vim.fn.jobstart(talk_to_sbt, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then
        return
      end

      log(vim.inspect(data))

      local handle_line = function(line)
        local ok, json = pcall(vim.fn.json_decode, line)
        if not ok or not json then
          log("could not parse: " .. vim.inspect(line))
          return
        end
        local message
        if json.params then
          message = json.params.message
        elseif json.error then
          message = json.error.message
        elseif json.result and json.result.status == "Done" then
          return
        end

        if not message then
          return
        end

        local check_for_error = function(reg, mess, error_mess)
          if reg:match_str(mess) then
            vim.schedule(function()
              vim.notify(error_mess, "error", {
                title = "Aria Deploy"
              })
            end)
            return true
          else
            return false
          end
        end

        local possible_errors = {
          { regex = compilation_failed, message = "Compilation failed...aborting deploy" },
          { regex = docker_not_running, message = "Docker is not running" },
          { regex = not_on_vpn, message = "Not on VPN or Harbor down" },
          { regex = possible_internet_down, message = "Could not connect. Internet possibly down" },
          { regex = nonzero_error, message = "A nonzero exit value occurred" },
          { regex = other_error, message = "An error occurred" }
        }

        for _, possible_error in pairs(possible_errors) do
          if (check_for_error(possible_error.regex, message, possible_error.message)) then
            return
          end
        end

        log("message: " .. vim.inspect(message))

        if published(deployment):match_str(message) then
          local published_hash = message:gsub("(.*):([%w%-]+)(.*)", "%2")
          if (string.len(published_hash) < 36) then
            vim.schedule(function()
              vim.notify("Could not build full hash: " .. published_hash, vim.log.levels.ERROR, {
                title = "Aria Deploy"
              })
            end)
          end

          vim.schedule(function()
            vim.notify("Starting deploy " .. published_hash, vim.log.levels.INFO, {
              title = "Aria Deploy"
            })
          end)

          local do_work = function(json_str)
            local json = vim.fn.json_decode(json_str)
            local image = json.spec.template.spec.containers[1].image
            local image_r = vim.regex(deployment .. ":.*$")
            if image_r:match_str(image) then
              local hash = image:gsub("(.*):(.*)", "%2")
              if (hash == published_hash) then
                restart_image(ns, deployment)
              elseif (hash == "latest") then
                deploy_image(ns, published_hash, deployment)
                restart_image(ns, deployment)
              else
                deploy_image(ns, published_hash, deployment)
              end
            end
          end

          get_deployment_json(ns, deployment, do_work)
        end
      end

      for _, line in ipairs(data) do
        local clean_line = line:gsub("}Content.*$", "}")
        clean_line = clean_line:gsub("^Content[^{]*{", "{")
        local i, _ = string.find(clean_line, "{")
        if i == 1 then
          handle_line(clean_line)
        end
      end
      log("Disconnected from SBT")
    end
  })

  log("chan_id: " .. chan_id)

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  local regex = vim.regex("^[^#]")
  for _, service in pairs(lines) do
    if regex:match_str(service) then
      local camel_service = string.gsub(service, "%-(%w)", function(s) return string.upper(s) end)
      log("publishing: " .. camel_service)
      vim.api.nvim_chan_send(chan_id,
        '{ "jsonrpc": "2.0", "id": 2, "method": "sbt/exec", "params": { "commandLine": "' ..
        camel_service .. ' / Docker / publish" } }')
      vim.api.nvim_chan_send(chan_id, "\n")
      deployment = service
    end
  end
end

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = ".deploy/*",
  callback = function()
    vim.bo.bufhidden = 'wipe'
    vim.bo.buflisted = false
    vim.bo.commentstring = "#%s"
  end,
  group = gid
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = ".deploy/*",
  callback = function(opts)
    local namespace = string.gsub(opts["file"], "(.*)/(.*)$", "%2")
    deploy(namespace)
  end,
  group = gid
})

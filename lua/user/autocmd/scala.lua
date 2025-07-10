local function setup_dap()
  local dap = require('dap')
  require('metals').setup_dap()

  -- dap.configurations.scala = {
  --   {
  --     type = "scala",
  --     request = "launch",
  --     name = "Run",
  --     metals = {
  --       runType = "run"
  --       -- again... example, don't leave these in here
  --       -- args = { "firstArg", "secondArg", "thirdArg" },
  --     }
  --   },
  --   {
  --     type = "scala",
  --     request = "launch",
  --     name = "Test File",
  --     metals = {
  --       runType = "testFile",
  --       jvmOptions = { "-Xms1024m", "-Xmx1024m", "-Xss4m", "-XX:ReservedCodeCacheSize=128m" },
  --       jvmOpts = { "-Xms1024m", "-Xmx1024m", "-Xss4m", "-XX:ReservedCodeCacheSize=128m" },
  --       jvmopts = { "-Xms1024m", "-Xmx1024m", "-Xss4m", "-XX:ReservedCodeCacheSize=128m" },
  --     },
  --   },
  --   {
  --     type = "scala",
  --     request = "launch",
  --     name = "Test Target",
  --     metals = {
  --       runType = "testTarget",
  --     },
  --   },
  -- }
  dap.configurations.scala = {
    {
      type = "scala",
      request = "launch",
      name = "Run or Test Target",
      metals = {
        runType = "runOrTestFile",
      },
    },
    {
      type = "scala",
      request = "launch",
      name = "Test Target",
      metals = {
        runType = "testTarget",
      },
    },
  }

  local dapui = require("dapui")
  dapui.setup()

  dap.listeners.before.event_initialized["dapui_config"] = function(session, body)
    if (session.config.name == "Launch debugger") then
      local bufnr = vim.api.nvim_get_current_buf()
      vim.cmd.tabnew()
      local tabnr = vim.api.nvim_get_current_tabpage()
      vim.api.nvim_set_current_buf(bufnr)
      dapui.open()
    else
      dap.repl.open()
    end
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
    -- print(vim.inspect(session))
    -- if (session.config.name == "Launch debugger") then
    --   dapui.close()
    --   if (tabnr) then
    --     vim.api.nvim_set_current_tabpage(tabnr)
    --     vim.cmd.tabclose()
    --     tabnr = nil
    --   end
    -- else
    --   print(body)
    --   dap.repl.open()
    -- end
  end
  dap.listeners.after.event_terminated["dapui_config"] = function()
    dapui.close()
    -- print(vim.inspect(session))
    -- if (session.config.name == "Launch debugger") then
    --   dapui.close()
    --   if (tabnr) then
    --     vim.api.nvim_set_current_tabpage(tabnr)
    --     vim.cmd.tabclose()
    --     tabnr = nil
    --   end
    -- else
    --   print(body)
    --   dap.repl.open()
    -- end
  end
  dap.listeners.before.event_exited["dapui_config"] = function(session, body)
    dapui.close()
    -- print(vim.inspect(session))
    -- if (session.config.name == "Launch debugger") then
    --   dapui.close()
    --   if (tabnr) then
    --     vim.api.nvim_set_current_tabpage(tabnr)
    --     vim.cmd.tabclose()
    --     tabnr = nil
    --   end
    -- else
    --   print(body)
    --   dap.repl.open()
    -- end
  end
  dap.listeners.after.event_exited["dapui_config"] = function(session, body)
    dapui.close()
    -- print(vim.inspect(session))
    -- if (session.config.name == "Launch debugger") then
    --   dapui.close()
    --   if (tabnr) then
    --     vim.api.nvim_set_current_tabpage(tabnr)
    --     vim.cmd.tabclose()
    --     tabnr = nil
    --   end
    -- else
    --   print(body)
    --   dap.repl.open()
    -- end
  end
  dap.listeners.before.event_cancel["dapui_config"] = function(sesh, body)
    dapui.close()
  end
  dap.listeners.before.event_stopped["dapui_config"] = function(sesh, body)
  end
  dap.listeners.after.event_output["dapui_config"] = function(sesh, body)
  end
  dap.listeners.after.event_progress_update["dapui_config"] = function(sesh, body)
  end
end

local gid = vim.api.nvim_create_augroup("scala", { clear = true })

sbt_instances = {}

local make_sbt_mapping

local Terminal = require('toggleterm.terminal').Terminal

local sbt_terminal = function(root_dir)
  local instance = sbt_instances[root_dir]
  if instance then
    return instance
  end

  instance = Terminal:new({
    cmd = "sbt",
    hidden = true,
    display_name = "SBT",
    direction = "float",
    close_on_exit = true,
    dir = root_dir,
    on_open = function(_)
      make_sbt_mapping(root_dir)
    end
  })
  sbt_instances[root_dir] = instance
  return instance
end

make_sbt_mapping = function(root_dir)
  vim.keymap.set('n', '<localleader>s', function() sbt_terminal(root_dir):toggle() end, { buffer = true, desc = "SBT" })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt", "java" },
  callback = function()
    local metals = require('metals')
    local metals_config = metals.bare_config()
    metals_config.init_options.statusBarProvider = "off"
    metals_config.tvp = {
      panel_width = 40,
      panel_alignment = "left",
      toggle_node_mapping = "<CR>",
      node_command_mapping = "r",
      collapsed_sign = "▸",
      expanded_sign = "▾",
    }
    metals_config.settings = {
      -- icons = "unicode",                   -- hmm
      testUserInterface = "Test Explorer", -- lets see
      showImplicitArguments = true,
      showInferredType = true,
      scalafixRulesDependencies = {
        'com.github.liancheng::organize-imports:0.6.0',
        -- 'io.github.ghostbuster91::scalafix-unified:0.0.9', -- ThisBuild /  scalafixDependencies += "io.github.ghostbuster91.scalafix-unified" %% "unified" % "<version>"
        "org.typelevel::typelevel-scalafix:0.2.0" -- ThisBuild / scalafixDependencies += "org.typelevel" %% "typelevel-scalafix" % "0.2.0"
        -- "com.nequissimus::sort-imports:0.6.1"
      },
      autoImportBuild = "all",
      -- enableBestEffort = true
    }

    -- local capabilities = vim.lsp.protocol.make_client_capabilities()
    local lsp_selection_range = require('lsp-selection-range')
    -- Update existing capabilities
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    capabilities = lsp_selection_range.update_capabilities(capabilities)
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities = vim.tbl_deep_extend(
      "force",
      capabilities,
      -- returns configured operations if setup() was already called
      -- or default operations if not
      require 'lsp-file-operations'.default_capabilities()
    )

    metals_config.capabilities = capabilities

    metals_config.on_attach = function(client, bufnr)
      vim.keymap.set('v', 'K', require('metals').type_of_range,
        { noremap = true, silent = true, buffer = bufnr, desc = "Show Type Information" })

      vim.keymap.set('n', '<localleader>m', require('metals').commands, { buffer = bufnr, desc = "Metals commands" })

      make_sbt_mapping(client.root_dir)

      setup_dap()
    end

    metals.initialize_or_attach(metals_config)
  end,
  group = gid
})

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = { "*/.metals/readonly/*", ".metals/readonly/*" },
  callback = function()
    vim.bo.buflisted = false
  end,
  group = gid
})

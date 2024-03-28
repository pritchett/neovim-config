local needs_dap_setup = true

local function setup_dap()
  local dap = require('dap')

  dap.configurations.scala = {
    {
      type = "scala",
      request = "launch",
      name = "Run",
      metals = {
        runType = "run"
        -- again... example, don't leave these in here
        -- args = { "firstArg", "secondArg", "thirdArg" },
      }
    },
    {
      type = "scala",
      request = "launch",
      name = "Test File",
      metals = {
        runType = "testFile",
        jvmOptions = { "-Xms1024m", "-Xmx1024m", "-Xss4m", "-XX:ReservedCodeCacheSize=128m" },
        jvmOpts = { "-Xms1024m", "-Xmx1024m", "-Xss4m", "-XX:ReservedCodeCacheSize=128m" },
        jvmopts = { "-Xms1024m", "-Xmx1024m", "-Xss4m", "-XX:ReservedCodeCacheSize=128m" },
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
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close("sidebar")
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close("sidebar")
  end

  local metals = require('metals')
  metals.setup_dap()
  needs_dap_setup = false
end

local function configure()
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
    showImplicitArguments = true
  }

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local lsp_selection_range = require('lsp-selection-range')
  -- Update existing capabilities
  capabilities = lsp_selection_range.update_capabilities(capabilities)
  local cmp_extended_capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
  -- cmp_extended_capabilities.textDocument.completion.completionItem.snippetSupport = true

  metals_config.capabilities = cmp_extended_capabilities

  metals_config.on_attach = function(client, bufnr)
    if (needs_dap_setup) then setup_dap() end
    vim.keymap.set('v', 'K', metals.type_of_range,
      { noremap = true, silent = true, buffer = bufnr, desc = "Show Type Information" })
  end
  metals.initialize_or_attach(metals_config)
  require("telescope").load_extension('metals')
end

local gid = vim.api.nvim_create_augroup("scala", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt" },
  callback = function()
    configure()
    vim.wo.number = true
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

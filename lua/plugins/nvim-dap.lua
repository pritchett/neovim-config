---@type LazySpec
return {
  "mfussenegger/nvim-dap",
  keys = {
    {
      '<leader>dr',
      mode = { 'n' },
      "<CMD>lua require'dap'.repl.toggle()<CR>"
    },
    {
      '<leader>db',
      mode = { 'n' },
      "<CMD>lua require'dap'.toggle_breakpoint()<CR>"
    },
    {
      '<F5>',
      mode = { 'n' },
      function() require('dap').continue() end,
      desc = "Continue"
    },
    {
      '<F6>',
      mode = { 'n' },
      function() require('dap').step_into() end,
      desc = "Step Into"
    },
    {
      '<F7>',
      mode = { 'n' },
      function() require('dap').step_over() end,
      desc = "Step Over"
    },
    {
      '<F8>',
      mode = { 'n' },
      function() require('dap').step_out() end,
      desc = "Step Out"
    },
    {
      '<F10>',
      mode = { 'n' },
      function() require('dap').run_to_cursor() end,
      desc = "Run To Cursor"
    },
    {
      '<Leader>dB',
      mode = { 'n' },
      function() require('dap').set_breakpoint() end,
      desc = 'DAP Set Breakpoint'
    },
    {
      '<Leader>dlp',
      mode = { 'n' },
      function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end
    },
    {
      '<Leader>dl',
      mode = { 'n' },
      function() require('dap').run_last() end
    },
    {
      '<Leader>dh',
      mode = { 'n', 'v' },
      function()
        require('dap.ui.widgets').hover()
      end
    },
    {
      '<Leader>dK',

      mode = { 'n', 'v' },
      function()
        require('dap.ui.widgets').hover()
      end
    },
    {
      '<Leader>dp',
      mode = { 'n', 'v' },
      function()
        require('dap.ui.widgets').preview()
      end
    },
    {
      '<Leader>df',
      mode = { 'n' },
      function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.frames)
      end
    },
    {
      '<Leader>ds',
      mode = 'n',
      function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.scopes)
      end
    },
    {
      '<Leader>dt',
      mode = { 'n' },
      function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.threads)
      end
    }

  },
  event = "VeryLazy"
}
-- vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
-- vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)

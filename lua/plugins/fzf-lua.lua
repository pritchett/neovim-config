return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    -- "hide",
    fzf_opts = { ['--cycle'] = true },
    winopts = {
      split = "botright new",
      on_create = function()
        local config = vim.api.nvim_win_get_config(0)
        vim.keymap.set("t", "<C-r>", [['<C-\><C-N>"'.nr2char(getchar()).'pi']], { expr = true, buffer = true })
        if (vim.o.lines * 0.30 > config.height) then
          vim.api.nvim_win_set_height(0, math.floor(vim.o.lines * 0.30))
          require('fzf-lua').redraw()
        end
      end
    }
  },
  config = function(_, opts)
    local fzf = require('fzf-lua')
    fzf.setup(opts)
    fzf.register_ui_select()
  end,
  event = "VeryLazy",
  keys = {
    {
      '<D-b>',
      mode = { 'n' },
      '<CMD>FzfLua buffers<CR>',
      desc = "List Buffers"
    },
    {
      '<Leader><Space>',
      mode = { 'n', 'v' },
      function()
        local fzf = require('fzf-lua')
        fzf.commands({
          sort_lastused = true,
          actions = {
            ["default"] = {
              fn = function(cmd)
                vim.schedule(function() vim.cmd(table.concat(cmd)) end)
              end
            }
          }
        })
      end,
      desc = "Command Pallete"
    },
    {
      '<Leader>r',
      mode = { 'n' },
      function() require('fzf-lua').resume() end,
      desc = 'Resume last picker'
    }
  }
}

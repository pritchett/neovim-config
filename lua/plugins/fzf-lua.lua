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
  event = "VeryLazy"
}

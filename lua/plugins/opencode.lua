return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for default `toggle()` implementation.
    -- { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    _G.opencode_instances = {}
    local Terminal = require('toggleterm.terminal').Terminal
    local function create_or_retrieve()
      local term = _G.opencode_instances[vim.fn.getcwd()]
      if not term then
        term = Terminal:new({
          cmd = "opencode",
          hidden = true,
          display_name = "OpenCode",
          direction = "vertical",
          close_on_exit = true
        })
      end

      _G.opencode_instances[vim.fn.getcwd()] = term
      return term
    end
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".

      provider = {
        toggle = function(self)
          create_or_retrieve():toggle()
        end,
        start = function(self)
          -- Called when sending a prompt or command to `opencode` but no process was found.
          -- `opencode.nvim` will poll for a couple seconds waiting for one to appear.

          create_or_retrieve():open()
        end,
        show = function(self)
          _G.opencode_instances[vim.fn.getcwd()]:show()
          -- Called when a prompt or command is sent to `opencode`,
          -- *and* this provider's `toggle` or `start` has previously been called
          -- (so as to not interfere when `opencode` was started externally).
        end
      }
    }
    -- vim.g.opencode_opts.instances = {}
    -- Required for `opts.auto_reload`.
    vim.o.autoread = true

    -- Recommended/example keymaps.
    vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end,
      { desc = "Ask opencode" })
    vim.keymap.set({ "n", "x" }, "<leader>ox", function() require("opencode").select() end,
      { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "x" }, "<leader>oga", function() require("opencode").prompt("@this") end,
      { desc = "Add to opencode" })
    vim.keymap.set({ "n", "t" }, "<leader>o.", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
    vim.keymap.set("n", "<A-u>", function() require("opencode").command("session.half.page.up") end,
      { desc = "opencode half page up" })
    vim.keymap.set("n", "<A-d>", function() require("opencode").command("session.half.page.down") end,
      { desc = "opencode half page down" })
    -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
    -- vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment', noremap = true })
    -- vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement', noremap = true })
  end,
}

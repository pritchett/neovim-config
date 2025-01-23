return {
  "lewis6991/gitsigns.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    on_attach = function()
      local gs = require("gitsigns")
      vim.keymap.set('n', '[g', function() gs.nav_hunk("prev") end, { desc = "Previous hunk" })
      vim.keymap.set('n', '[G',
        function() gs.nav_hunk("prev", { preview = true }) end, { desc = "Previous hunk with preview" })
      vim.keymap.set('n', ']g', function() gs.nav_hunk("next") end, { desc = "Next hunk" })
      vim.keymap.set('n', ']G',
        function() gs.nav_hunk("next", { preview = true }) end, { desc = "Next hunk with preview" })
    end
  },
  event = "VeryLazy"
}

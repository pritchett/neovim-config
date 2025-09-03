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
      vim.keymap.set('n', '<D-g>p', function() gs.preview_hunk() end, { desc = "Preview hunk" })
      vim.keymap.set('n', '<D-g>b', function() gs.blame_line() end, { desc = "Blame hunk" })
      vim.keymap.set('n', '<D-g>s', function() gs.stage_hunk() end, { desc = "Stage hunk" })
      vim.keymap.set('n', '<D-g>r', function() gs.reset_hunk() end, { desc = "Reset hunk" })
    end
  },
  event = "VeryLazy"
}

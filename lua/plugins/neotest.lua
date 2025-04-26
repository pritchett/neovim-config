return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "stevanmilic/neotest-scala",
    "mrcjkb/neotest-haskell"
  },
  -- opts = {
  --   adapters = {
  --     require("neotest-scala")({
  --       framework = "scalatest"
  --     }),
  --   }
  -- },
  config = function()
    require("neotest").setup({
      consumers = {
        overseer = require("neotest.consumers.overseer"),
      },
      adapters = {
        require("neotest-scala")({
          framework = "scalatest"
        }),
        require('rustaceanvim.neotest')
      }
    })
  end,
  cmd = "Neotest"
}

return {
   "nvim-neotest/neotest",
   dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "stevanmilic/neotest-scala",
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
         adapters = {
            require("neotest-scala")({
               framework = "scalatest",
            }),
         },
      })
   end,
   cmd = "Neotest",
}

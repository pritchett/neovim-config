return {
  "NeogitOrg/neogit",
  dependencies = "nvim-lua/plenary.nvim",
  cmd = "Neogit",
  opts = {
    graph_style = "kitty"
  }

  -- config = function()
  --   require("neogit").setup({
  --     -- integrations = {
  --     -- telescope = , -- If these are set to true, it disables the integration. Great api.
  --     -- diffview = true,
  --     -- },
  --   })
  -- end,
}

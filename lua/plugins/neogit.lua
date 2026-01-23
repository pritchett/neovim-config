return {
   "NeogitOrg/neogit",
   dependencies = "nvim-lua/plenary.nvim",
   cmd = "Neogit",
   opts = {
      graph_style = "kitty",
      git_services = {
         ["gitlab.idine.com"] = "https://gitlab.idine.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
      },
   },
   keys = {
      {
         "<leader>g",
         mode = { "n" },
         "<CMD>Neogit<CR>",
         desc = "Neogit",
      },
      -- config = function()
      --   require("neogit").setup({
      --     -- integrations = {
      --     -- telescope = , -- If these are set to true, it disables the integration. Great api.
      --     -- diffview = true,
      --     -- },
      --   })
      -- end,
   },
}

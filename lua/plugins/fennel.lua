return {
   { "bakpakin/fennel.vim" },
   { "HiPhish/rainbow-delimiters.nvim" },
   {
      "kylechui/nvim-surround",
      version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
      event = "VeryLazy",
      config = function()
         require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
         })
      end,
   },
   {
      "julienvincent/nvim-paredit",
      config = function()
         require("nvim-paredit").setup()
      end,
   },
   -- {
   --   'frazrepo/vim-rainbow',
   --   config = function()
   --     vim.g.rainbow_ctermfgs = {
   --       'red',
   --       'yellow',
   --       'green',
   --       'cyan',
   --       'magenta',
   --       'gray'
   --     }
   --   end
   -- },
   { "tpope/vim-sexp-mappings-for-regular-people" },
}

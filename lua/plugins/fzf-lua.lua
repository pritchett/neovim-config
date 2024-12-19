return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    winopts = {
      split = "botright new",
      height = 30
    }
  }
  -- config = function()
  --   -- calling `setup` is optional for customization
  --   require("fzf-lua").setup({})
  -- end
}

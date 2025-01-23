return {
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  opts = true,
  config = function(_, _)
    require("lsp_lines").setup()
    vim.keymap.set("n", "<leader>L", require('lsp_lines').toggle)
  end,
  event = "VeryLazy"
}

return {
  "stevearc/oil.nvim",
  opts = {
    skip_confirm_for_simple_edits = true,
    lsp_file_methods = {
      -- Enable or disable LSP file operations
      enabled = true,
      -- Time to wait for LSP file operations to complete before skipping
      timeout_ms = 1000,
      -- Set to true to autosave buffers that are updated with LSP willRenameFiles
      -- Set to "unmodified" to only save unmodified buffers
      autosave_changes = "unmodified",
    },
    win_options = {
      signcolumn = "yes:2"
    }
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  enabled = true
}

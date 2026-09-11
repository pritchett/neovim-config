return {
   "stevearc/conform.nvim",
   opts = {
      formatters = {
         ["scala-cli"] = {
            command = "scala-cli",
            args = { "format", "--scalafmt-arg", "--stdin", "--scalafmt-arg", "--stdout" },
         },
         kulala = {
            command = "kulala-fmt",
            args = { "format", "$FILENAME" },
            stdin = false,
         },
         injected = {
            options = {
               lang_to_formatters = {
                  scala = { "scala-cli" },
               },
            },
         },
      },
      formatters_by_ft = {
         fennel = { "fnlfmt" },
         scala = { "scala-cli" },
         lua = { "stylua" },
         markdown = { "injected" },
         http = { "kulala" },
         xml = { "xmlformat" },
      },
      format_after_save = {
         -- These options will be passed to conform.format()
         timeout_ms = 1000,
         -- lsp_format = "fallback",
         lsp_format = "fallback",
         callback = function(err, did_edit)
            if err then
               return
            end
            if did_edit then
               vim.fn.edit()
            end
         end,
      },
   },
}

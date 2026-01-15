return {
	"stevearc/conform.nvim",
	opts = {
		formatters = {
			["scala-cli"] = {
				command = "scala-cli",
				args = { "format", "--scalafmt-arg", "--stdin", "--scalafmt-arg", "--stdout" },
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
			scala = { "scalafmt" },
			lua = { "stylua" },
			markdown = { "injected" },
		},
		format_on_save = {
			-- These options will be passed to conform.format()
			timeout_ms = 1000,
			-- lsp_format = "fallback",
			lsp_format = "fallback",
		},
	},
}

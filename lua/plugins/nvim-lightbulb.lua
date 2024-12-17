return {
  "kosayoda/nvim-lightbulb",
  enabled = false,
  opts = {
    autocmd = {
      enabled = true,
    },
    ignore = {
      -- Ignore code actions without a `kind` like refactor.rewrite, quickfix.
      actions_without_kind = true,
    },
  }
}

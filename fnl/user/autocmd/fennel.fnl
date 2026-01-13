(fn augroup [group args]
  "Wrapper around creating augroups"
  (vim.api.nvim_create_augroup group args))

(vim.api.nvim_create_autocmd :BufWritePost
                             {:desc "Format fennel files"
                              :pattern :*.fnl
                              :group (augroup :fennel {:clear true})
                              :callback (fn [_] (vim.cmd "!fnlfmt --fix %")
                                          (vim.cmd.edit))})

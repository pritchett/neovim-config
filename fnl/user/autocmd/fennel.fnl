(fn augroup [group args]
  "Wrapper around creating augroups"
  (vim.api.nvim_create_augroup group args))

(let [fennel-group (augroup :fennel {:clear true})]
  (vim.api.nvim_create_autocmd :BufWritePost
                               {:desc "Format fennel files"
                                :pattern :*.fnl
                                :group fennel-group
                                :callback (fn [_]
                                            (vim.cmd "silent !fnlfmt --fix %")
                                            (vim.cmd.edit)
                                            nil)}))

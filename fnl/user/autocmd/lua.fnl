(let [fnl-group (vim.api.nvim_create_augroup :fennel {:clear true})]
  (vim.api.nvim_create_autocmd :FileType
                               {:pattern :lua
                                :group fnl-group
                                :callback (fn [data]
                                            (vim.keymap.set :n :K
                                                            vim.lsp.buf.hover
                                                            {:buffer data.buf})
                                            nil)}))

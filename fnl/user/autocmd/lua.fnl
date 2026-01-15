(vim.api.nvim_create_autocmd :FileType
                             {:pattern :lua
                              :callback (fn [data]
                                          (vim.keymap.set :n :K
                                                          vim.lsp.buf.hover
                                                          {:buffer (. data :buf)}))})

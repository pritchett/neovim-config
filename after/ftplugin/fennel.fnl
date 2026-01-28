(local paredit (require :nvim-paredit))

(vim.keymap.set :n "'c-]'" (.. vim.g.maplocalleader :gd)
                {:buffer true :remap true})

(vim.keymap.set :n :O (fn []
                        (paredit.api.move_to_parent_form_start)
                        (vim.cmd.normal "i() ")
                        (vim.cmd.normal :gqap)
                        (vim.fn.search "(nil)")
                        (vim.cmd.normal :l)
                        (vim.cmd.normal :diw)
                        (vim.cmd.startinsert))
                {:buffer true})

(vim.keymap.set :n :o (fn []
                        (paredit.api.move_to_parent_form_end)
                        (vim.cmd.normal "a () ")
                        (vim.cmd.normal :gqap)
                        (vim.fn.search "(nil)")
                        (vim.cmd.normal :l)
                        (vim.cmd.normal :diw)
                        (vim.cmd.startinsert))
                {:buffer true})

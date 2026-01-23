vim.keymap.set("n", "gO", "<CMD>Neorg toc<CR>", { buffer = true })
vim.keymap.set("n", "<Leader>ot", "<CMD>Neorg toggle-concealer<CR>", { buffer = true, desc = "Toggle concealer" })

vim.keymap.set("n", "]]", function()
   vim.cmd([[ call search("^\\s*\\*") ]])
end, { buffer = true })
vim.keymap.set("n", "[[", function()
   vim.cmd([[ call search("^\\s*\\*", "b") ]])
end, { buffer = true })

vim.keymap.set("n", "<up>", "<Plug>(neorg.text-objects.item-up)", { buffer = true })
vim.keymap.set("n", "<down>", "<Plug>(neorg.text-objects.item-down)", { buffer = true })
vim.keymap.set({ "o", "x" }, "iH", "<Plug>(neorg.text-objects.textobject.heading.inner)", { buffer = true })
vim.keymap.set({ "o", "x" }, "aH", "<Plug>(neorg.text-objects.textobject.heading.outer)", { buffer = true })

vim.keymap.set({ "o", "x" }, "iH", "<Plug>(neorg.text-objects.textobject.heading.inner)", { buffer = true })
vim.keymap.set({ "o", "x" }, "aH", "<Plug>(neorg.text-objects.textobject.heading.outer)", { buffer = true })

vim.keymap.set({ "n" }, "<localleader>n", "<Plug>(neorg.presenter.next-page)", { buffer = true })
vim.keymap.set({ "n" }, "<localleader>p", "<Plug>(neorg.presenter.previous-page)", { buffer = true })
vim.keymap.set({ "n" }, "<localleader>c", "<Plug>(neorg.presenter.close)", { buffer = true })

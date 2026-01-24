-- [nfnl] fnl/after/ftplugin/fennel.fnl
return vim.keymap.set("n", "<c-]>", (vim.g.maplocalleader .. "gd"), {buffer = true, remap = true})

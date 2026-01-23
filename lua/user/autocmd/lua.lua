-- [nfnl] fnl/user/autocmd/lua.fnl
local fnl_group = vim.api.nvim_create_augroup("fennel", { clear = true })
local function _1_(data)
   vim.keymap.set("n", "K", vim.lsp.buf.hover, n, { buffer = data.buf })
   return nil
end
return vim.api.nvim_create_autocmd("FileType", { pattern = "lua", group = fnl_group, callback = _1_ })

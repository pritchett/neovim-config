-- [nfnl] fnl/user/autocmd/lua.fnl
local function _1_(data)
  return vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer = data.buf})
end
return vim.api.nvim_create_autocmd("FileType", {pattern = "lua", callback = _1_})

-- [nfnl] fnl/user/autocmd/fennel.fnl
local function augroup(group, args)
  return vim.api.nvim_create_augroup(group, args)
end
local function _1_(_)
  vim.cmd("!fnlfmt --fix %")
  return vim.cmd.edit()
end
return vim.api.nvim_create_autocmd("BufWritePost", {desc = "Format fennel files", pattern = "*.fnl", group = augroup("fennel", {clear = true}), callback = _1_})

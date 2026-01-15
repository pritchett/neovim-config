-- [nfnl] fnl/user/autocmd/fennel.fnl
local function augroup(group, args)
  return vim.api.nvim_create_augroup(group, args)
end
local fennel_group = augroup("fennel", {clear = true})
local function _1_(_)
  vim.cmd("silent !fnlfmt --fix %")
  vim.cmd.edit()
  return nil
end
return vim.api.nvim_create_autocmd("BufWritePost", {desc = "Format fennel files", pattern = "*.fnl", group = fennel_group, callback = _1_})

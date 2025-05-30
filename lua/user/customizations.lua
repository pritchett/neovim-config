local M                    = {}

local gitsigns_namespaces  = { gitsigns = true, gitsigns_blame = true, gitsigns_removed = true, gitsigns_signs_ = true, gitsigns_signs_staged = true }

M.get_signs_minus_gitsigns = function()
  if vim.v.virtnum < 0 then return "" end
  local line = ""
  for k, ns in pairs(vim.api.nvim_get_namespaces()) do
    if gitsigns_namespaces[k] == nil then
      local signs = vim.api.nvim_buf_get_extmarks(0, ns, { vim.v.lnum - 1, 0 }, { vim.v.lnum - 1, -1 }, { type = "sign" })
      for _, sign in ipairs(signs) do
        local sign_id = sign[1]
        local details = vim.api.nvim_buf_get_extmark_by_id(0, ns, sign_id, { details = true })[3]
        if (details and details.sign_hl_group) then
          line = line .. '%#' .. details.sign_hl_group .. '#'
        end
        if (details and details.sign_text) then
          line = line .. details.sign_text
        end
        if line ~= "" then
          return line
        end
      end
    end
  end
  return line
end

M.get_gitsigns_sign_column = function()
  if vim.v.virtnum < 0 then return "" end
  local ns = vim.api.nvim_get_namespaces().gitsigns_signs_
  if not ns then
    return ""
  end
  -- There should only ever be one sign from Gitsigns here
  local gitsigns = vim.api.nvim_buf_get_extmarks(0, ns, { vim.v.lnum - 1, 0 }, { vim.v.lnum - 1, -1 }, { type = "sign" })
  for _, sign in ipairs(gitsigns) do
    local sign_id = sign[1]
    local details = vim.api.nvim_buf_get_extmark_by_id(0, ns, sign_id, { details = true })[3]
    return details and '%#' .. details.sign_hl_group .. '#' .. details.sign_text
  end
  return ""
end

M.get_fold_column          = function()
  local fillchars = vim.opt.fillchars:get()
  local fold_line_before = vim.fn.foldlevel(vim.v.lnum - 1)
  local fold_line_curr = vim.fn.foldlevel(vim.v.lnum)
  local increased_fold = fold_line_curr > fold_line_before
  if increased_fold and vim.fn.foldclosed(vim.v.lnum) == vim.v.lnum then
    return fillchars.foldclose or ""
  elseif increased_fold then
    return fillchars.foldopen or ""
  elseif fold_line_curr > 0 then
    return fillchars.foldsep or ""
  end
  return fillchars.fold or ""
end

M.lsp_statuscolumn         = table.concat({
  "%-02(%{%v:lua.require('user.customizations').get_signs_minus_gitsigns()%}%)",
  "%l",
  "%-02(%{%v:lua.require('user.customizations').get_gitsigns_sign_column()%}%)",
  "%-02{%v:lua.require('user.customizations').get_fold_column()%}",
})

return M

local M = {}

M.lsp_statuscolumn =
[[%=%04(%{%v:lua.get_signs_minus_gitsigns()%}%)%(%{%v:lnum==line('.')?'%#CursorLineNR#':'%#LineNR#'%}%-l%)%02(%=%{%v:lua.get_gitsigns_sign_column()%}%)%01(%{%v:lnum==line('.')?'%#CursorLineNR#':'%#LineNR#'%}%{%v:lua.get_fold_column()%}%)]]

return M

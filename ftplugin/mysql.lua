local ns = vim.api.nvim_create_namespace('sql highlights')
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'TextChanged', 'TextChangedI', 'CursorHold' }, {
  buffer = 0,
  callback = function(_)
    local ext_marks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {
      type = 'virt_text',
      details = false
    })

    for _, ext_mark in ipairs(ext_marks) do
      vim.api.nvim_buf_del_extmark(0, ns, ext_mark[1])
    end
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for idx, line in ipairs(lines) do
      local api_idx = idx - 1
      local bind_params = vim.b.dbui_bind_params or {}
      for k, v in pairs(bind_params) do
        local start, end_of_pattern = line:find(k)
        if (start) then
          vim.api.nvim_buf_set_extmark(0, ns, api_idx, start - 1, {
            end_row = api_idx,
            end_col = end_of_pattern - 1,
            virt_text = { { " " .. k .. " -> " .. v, "@string" } },
            virt_text_pos = 'eol'
          })
        end
      end
    end
  end
})

vim.cmd.inoreabbrev('<buffer> select SELECT')
vim.cmd.inoreabbrev('<buffer> from FROM')
vim.cmd.inoreabbrev('<buffer> where WHERE')
vim.cmd.inoreabbrev('<buffer> join JOIN')

vim.keymap.set('n', '<localleader>u', [[i<C-R>=tolower(trim(system('uuidgen')))<CR><ESC>]],
  { buffer = true, desc = "Insert UUID" })
vim.keymap.set('v', '<localleader>u', [[xi<C-R>=tolower(trim(system('uuidgen')))<CR><ESC>gv]],
  { buffer = true, desc = "Insert UUID" })

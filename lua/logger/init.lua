local M = {}

local new_logging_buffer = function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "filetype","log")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.g.LoggerBufNr = bufnr
  return bufnr
end

local get_logging_buffer = function()
  local bufnr = vim.g.LoggerBufNr
  if not bufnr then
    bufnr = new_logging_buffer()
  end
  return bufnr
end

M.log = function(data)
  if not data then
    return
  end

  local bufnr = get_logging_buffer()
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines > 10000 then
    vim.api.nvim_buf_set_lines(bufnr, 0, 10000 - #lines, false, {})
  end
  if type(data) == 'string' then
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { data })
  elseif type(data) == 'table' then
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { data })
  end

  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

M.handler = function(_, data)
  if not data then return end
  local bufnr = get_logging_buffer()
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
end

M.toggle_log = function()

  local wins = vim.api.nvim_tabpage_list_wins(0)

  local log_bufnr = get_logging_buffer()
  local cur_winnr = vim.api.nvim_tabpage_get_win(0)
  for _, winnr in ipairs(wins) do
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    if bufnr == log_bufnr then
      if (winnr == cur_winnr) then
        vim.cmd.wincmd('p')
      end
      vim.api.nvim_win_close(winnr, true)
      return
    end
  end

  local bufs = vim.api.nvim_list_bufs()
  for _, bufnr in pairs(bufs) do
    if bufnr == log_bufnr then
      vim.cmd('split')
      local winnr = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(winnr, bufnr)
      vim.cmd.wincmd('L')
      vim.cmd.normal('G')
      return
    end
  end
end

return M

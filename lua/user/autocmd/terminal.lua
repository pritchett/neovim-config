local gid = vim.api.nvim_create_augroup("terminal", { clear = true})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "c:nt",
  callback = function()
    if not vim.b.last_command_mode_is_search then
      vim.cmd.startinsert()
      local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
      vim.api.nvim_feedkeys(esc, 'n', false)
      vim.b.terminal_mode = "NORMAL"
    end
  end,
  group = gid
})

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*t:c",
  callback = function()
    vim.b.terminal_mode = "COMMAND"
    local cmdtype = vim.fn.getcmdtype()
    if(cmdtype == "/" or cmdtype == "?") then
      vim.b.last_command_mode_is_search = true
    else
      vim.b.last_command_mode_is_search = false
    end
  end,
  group = gid
})

local char_esc_char = function(char)
  return char .. '<ESC>' .. char
end

local zsh_normal_mode = function()
  vim.b.terminal_mode = "NORMAL"
  if vim.b.last_command_mode_is_search then
    vim.b.last_command_mode_is_search  = false
    return
  end
  vim.cmd.startinsert()
  local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'n', false)
end

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.keymap.set('n', '<ESC>', zsh_normal_mode, { buffer = true, desc = "Change to normal mode in zsh"})
    vim.keymap.set('n', 'a', char_esc_char('a'), { buffer = true })
    vim.keymap.set('n', 'i', char_esc_char('i'), { buffer = true })
    vim.keymap.set('n', 'I', char_esc_char('I'), { buffer = true })
    vim.keymap.set('n', 'A', char_esc_char('A'), { buffer = true })
    vim.keymap.set('n', 's', char_esc_char('s'), { buffer = true })
    vim.keymap.set('n', 'o', char_esc_char('o'), { buffer = true })
    vim.keymap.set('n', 'O', char_esc_char('O'), { buffer = true })
    vim.keymap.set('n', 'gI', char_esc_char('gI'), { buffer = true })
    vim.keymap.set('n', 'gi', char_esc_char('gi'), { buffer = true })
    vim.b.terminal_mode = "INSERT"
  end,
  group = gid,
  desc = "Keymaps and mode setting for terminal passthrough"
})

vim.api.nvim_create_autocmd("TermEnter", {
  pattern = "*",
  callback = function()
    vim.o.number = false
    local bufname = vim.api.nvim_buf_get_name(0)
    if (vim.endswith(bufname, "metals.log")) then
      vim.cmd([[stopinsert]])
    else
      vim.cmd([[startinsert]])
    end
  end,
  group = gid
})

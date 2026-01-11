local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>L', '<CMD>TinyInlineDiag toggle<CR>')
vim.keymap.set('n', 'L', 'zL')
vim.keymap.set('n', 'H', 'zH')

vim.keymap.set('n', '<leader>p', '<CMD>Projects<CR>', { desc = "Projects" })

-- keymap('n', '<leader>e', "<CMD>new<BAR>e.<cr>", opts)
local edit_cwd = function()
  -- if vim.api.nvim_buf_get_name(0) == "" then
  vim.cmd.edit('.')
  -- else
  --   vim.cmd.new()
  --   vim.cmd.edit('.')
  -- end
end
vim.keymap.set('n', '<leader>e', edit_cwd, { desc = "Browse current directory" })
vim.keymap.set('n', 'g<leader>e', function()
  vim.cmd.split()
  edit_cwd()
end, { desc = "Browse current directory in new split" })

local edit_buffer_dir = function()
  local dir = vim.fn.expand('%:h')
  if dir == "" then
    vim.cmd.edit('.')
  else
    vim.cmd.edit(dir)
  end
end

vim.keymap.set('n', '<leader>E', edit_buffer_dir, { desc = "Open current buffer directory" })
vim.keymap.set('n', 'g<leader>E', function()
  vim.cmd.split()
  edit_buffer_dir()
end, { desc = "Open current buffer directory in split" })

vim.keymap.set('n', '<C-]>', "<C-]>zt", opts)
vim.keymap.set('n', '<C-W>m', "<C-W>_<C-W>|", opts)

-- vim.keymap.set('n', ']f', '<CMD>TSTextobjectGotoNextStart @function.outer<CR>')
-- vim.keymap.set('n', '[f', '<CMD>TSTextobjectGotoPreviousStart @function.outer<CR>')

-- vim.keymap.set('n', ']a', '<CMD>TSTextobjectGotoNextStart @parameter.inner<CR>')
-- vim.keymap.set('n', '[a', '<CMD>TSTextobjectGotoPreviousStart @parameter.inner<CR>')

-- vim.keymap.set('t', '<C-\\>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-;>', '<C-\\><C-n>')

vim.keymap.set('n', '<D-G>', '<CMD>FzfLua live_grep<CR>')

vim.keymap.set('n', '<leader>D', '<CMD>DBUIToggle<CR>')

vim.keymap.set('n', '<D-a>', '<CMD>FzfLua args<CR>')

-- Neorg
vim.keymap.set('n', '<Leader>oc', '<CMD>Neorg capture<CR>', { silent = true })

local function toggle_quickfix()
  local windows = vim.fn.getwininfo() or {}
  for _, win in pairs(windows) do
    if win["quickfix"] == 1 then
      vim.cmd.cclose()
      return
    end
  end

  local ok, err = pcall(vim.cmd.copen)
  if ok then
    vim.cmd.wincmd('J')
  else
    if err then
      vim.notify(err)
    else
      vim.notify("There was an issue with opening the quickfix")
    end
  end
end

vim.keymap.set('n', '<Leader>q', toggle_quickfix, { desc = "Toggle quickfix" })

--- terminal
-- vim.keymap.set('t', '<esc>', '<c-\\><c-n>', { desc = "normal mode" })

local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>L', function()
  vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines })
end)
vim.keymap.set('n', 'L', 'zL')
vim.keymap.set('n', 'H', 'zH')

vim.keymap.set('n', '<leader>p', '<CMD>Projects<CR>', { desc = "Projects" })

-- keymap('n', '<leader>e', "<CMD>new<BAR>e.<cr>", opts)
vim.keymap.set('n', '<leader>e', function()
  -- if vim.api.nvim_buf_get_name(0) == "" then
  vim.cmd.edit('.')
  -- else
  --   vim.cmd.new()
  --   vim.cmd.edit('.')
  -- end
end, { desc = "Browse directory" })
vim.keymap.set('n', '<leader>E', "<CMD>execute 'e ' . expand('%:h')<CR>", { desc = "Open current of buffer" })

vim.keymap.set('n', '<C-]>', "<C-]>zz", opts)
vim.keymap.set('n', '<C-W>m', "<C-W>_<C-W>|", opts)

vim.keymap.set('n', ']f', '<CMD>TSTextobjectGotoNextStart @function.outer<CR>')
vim.keymap.set('n', '[f', '<CMD>TSTextobjectGotoPreviousStart @function.outer<CR>')

vim.keymap.set('n', ']a', '<CMD>TSTextobjectGotoNextStart @parameter.inner<CR>')
vim.keymap.set('n', '[a', '<CMD>TSTextobjectGotoPreviousStart @parameter.inner<CR>')

-- vim.keymap.set('t', '<C-\\>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-;>', '<C-\\><C-n>')

-- Neorg
vim.keymap.set('n', '<Leader>oc', '<CMD>Neorg capture<CR>', { silent = true })

vim.keymap.set('n', '<a-n>', 'gt')
vim.keymap.set('n', '<a-p>', 'gT')

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



-- From smart-splits documentation
-- recommended mappings
-- resizing splits
-- these keymaps will also accept a range,
-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
vim.keymap.set('n', '<C-h>', require('smart-splits').resize_left)
vim.keymap.set('n', '<C-j>', require('smart-splits').resize_down)
vim.keymap.set('n', '<C-k>', require('smart-splits').resize_up)
vim.keymap.set('n', '<C-l>', require('smart-splits').resize_right)
-- moving between splits
vim.keymap.set('n', '<A-h>', require('smart-splits').move_cursor_left)
vim.keymap.set('n', '<A-j>', require('smart-splits').move_cursor_down)
vim.keymap.set('n', '<A-k>', require('smart-splits').move_cursor_up)
vim.keymap.set('n', '<A-l>', require('smart-splits').move_cursor_right)
vim.keymap.set('n', '<A-\\>', require('smart-splits').move_cursor_previous)
-- swapping buffers between windows
vim.keymap.set('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
vim.keymap.set('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
vim.keymap.set('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
vim.keymap.set('n', '<leader><leader>l', require('smart-splits').swap_buf_right)

-- -- Window management
-- vim.keymap.set('n', '<a-l>', '<CMD>wincmd l<CR>')
-- vim.keymap.set('n', '<a-h>', '<CMD>wincmd h<CR>')
-- vim.keymap.set('n', '<a-j>', '<CMD>wincmd j<CR>')
-- vim.keymap.set('n', '<a-k>', '<CMD>wincmd k<CR>')
-- vim.keymap.set('n', '<a-->', '<CMD>wincmd -<CR>')
-- vim.keymap.set('n', '<a-S-=>', '<CMD>wincmd +<CR>')
-- vim.keymap.set('n', '<a-=>', '<CMD>wincmd =<CR>')
-- vim.keymap.set('n', '<a-b>', '<CMD>wincmd b<CR>')
-- vim.keymap.set('n', '<a-p>', '<CMD>wincmd p<CR>')
-- vim.keymap.set('n', '<a-w>', '<CMD>wincmd w<CR>')
-- vim.keymap.set('n', '<a-t>', '<CMD>wincmd t<CR>')
-- vim.keymap.set('n', '<a-L>', '<CMD>wincmd L<CR>')
-- vim.keymap.set('n', '<a-H>', '<CMD>wincmd H<CR>')
-- vim.keymap.set('n', '<a-J>', '<CMD>wincmd J<CR>')
-- vim.keymap.set('n', '<a-K>', '<CMD>wincmd K<CR>')


--- terminal
-- vim.keymap.set('t', '<esc>', '<c-\\><c-n>', { desc = "normal mode" })

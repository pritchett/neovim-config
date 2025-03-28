return {
  'mrjones2014/smart-splits.nvim',
  build = './kitty/install-kittens.bash',
  lazy = false,
  opts = {
    ignored_buftypes = {
      'nofile',
      'quickfix',
      'prompt',
      'dbout',
      'dbui'
    }
  },
  keys = {
    { '<D-C-h>',  mode = { 'n' }, function() require('smart-splits').move_cursor_left() end },
    { '<D-C-j>',  mode = { 'n' }, function() require('smart-splits').move_cursor_down() end },
    { '<D-C-k>',  mode = { 'n' }, function() require('smart-splits').move_cursor_up() end },
    { '<D-C-l>',  mode = { 'n' }, function() require('smart-splits').move_cursor_right() end },
    { '<D-C-\\>', mode = { 'n' }, function() require('smart-splits').move_cursor_previous() end },
    { '<D-C-b>',  mode = { 'n' }, '<CMD>wincmd b<CR>' },
    { '<D-C-p>',  mode = { 'n' }, '<CMD>wincmd p<CR>' },
    { '<D-C-t>',  mode = { 'n' }, '<CMD>wincmd t<CR>' },
    { '<D-C-[>',  mode = { 'n' }, '<CMD>tabprev' },
    { '<D-C-]>',  mode = { 'n' }, '<CMD>tabnext<CR>' },

    { '<D-S-h>',  mode = { 'n' }, function() require('smart-splits').resize_left() end },
    { '<D-S-j>',  mode = { 'n' }, function() require('smart-splits').resize_down() end },
    { '<D-S-k>',  mode = { 'n' }, function() require('smart-splits').resize_up() end },
    { '<D-S-l>',  mode = { 'n' }, function() require('smart-splits').resize_right() end },

    -- swapping buffers between windows
    -- vim.keymap.set('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
    -- vim.keymap.set('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
    -- vim.keymap.set('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
    -- vim.keymap.set('n', '<leader><leader>l', require('smart-splits').swap_buf_right)
  }
}

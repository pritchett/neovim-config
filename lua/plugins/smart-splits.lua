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
    },
    resize_mode = {
      hooks = {
        on_leave = function()
          local br = require('bufresize')
          if (br == nil) then
            vim.notify("Make sure to install bufresize", vim.log.levels.WARN)
            return
          end
          br.register()
        end
      }
    }
  },
  keys = {
    { '<D-C-h>',  mode = { 'n', 't' }, function() require('smart-splits').move_cursor_left() end },
    { '<D-C-j>',  mode = { 'n', 't' }, function() require('smart-splits').move_cursor_down() end },
    { '<D-C-k>',  mode = { 'n', 't' }, function() require('smart-splits').move_cursor_up() end },
    { '<D-C-l>',  mode = { 'n', 't' }, function() require('smart-splits').move_cursor_right() end },
    { '<D-C-\\>', mode = { 'n', 't' }, function() require('smart-splits').move_cursor_previous() end },
    { '<D-C-b>',  mode = { 'n', 't' }, '<CMD>wincmd b<CR>' },
    { '<D-C-p>',  mode = { 'n', 't' }, '<CMD>wincmd p<CR>' },
    { '<D-C-t>',  mode = { 'n', 't' }, '<CMD>wincmd t<CR>' },
    { '<D-C-[>',  mode = { 'n', 't' }, '<CMD>tabprev<CR>' },
    { '<D-C-]>',  mode = { 'n', 't' }, '<CMD>tabnext<CR>' },

    { '<D-S-h>',  mode = { 'n', 't' }, function() require('smart-splits').resize_left() end },
    { '<D-S-j>',  mode = { 'n', 't' }, function() require('smart-splits').resize_down() end },
    { '<D-S-k>',  mode = { 'n', 't' }, function() require('smart-splits').resize_up() end },
    { '<D-S-l>',  mode = { 'n', 't' }, function() require('smart-splits').resize_right() end },

    -- swapping buffers between windows
    -- vim.keymap.set('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
    -- vim.keymap.set('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
    -- vim.keymap.set('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
    -- vim.keymap.set('n', '<leader><leader>l', require('smart-splits').swap_buf_right)
  }
}

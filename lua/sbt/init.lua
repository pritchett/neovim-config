local Terminal  = require('toggleterm.terminal').Terminal

local SBT = Terminal:new({
  cmd = "sbt",
  direction = "horizontal",
  on_open = function(t)
    vim.keymap.set('n', '<leader>s', function() t:toggle() end, { buffer = true })
  end,
  name = "SBT"
})

return SBT

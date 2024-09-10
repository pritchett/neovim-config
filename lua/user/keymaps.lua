local opts = { noremap = true, silent = true }

local keymap = vim.api.nvim_set_keymap

keymap('n', ']c', ':silent cnext<CR>', opts)
keymap('n', '[c', ':silent cprevious<CR>', opts)

keymap('n', '<Leader>bb', '<CMD>Telescope buffers theme=ivy<CR>', opts)
keymap('n', '<Leader><Space>', '<CMD>Telescope commands theme=ivy<CR>', opts)

local dap = require('dap')
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = "Continue" })
vim.keymap.set('n', '<F6>', function() require('dap').step_into() end, { desc = "Step Into" })
vim.keymap.set('n', '<F7>', function() require('dap').step_over() end, { desc = "Step Over" })
vim.keymap.set('n', '<F8>', function() require('dap').step_out() end, { desc = "Step Out" })
vim.keymap.set('n', '<F10>', dap.run_to_cursor, { desc = "Run To Cursor" })
-- vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>dB', function() require('dap').set_breakpoint() end)
vim.keymap.set('n', '<Leader>dlp',
  function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
-- vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dK', function()
  require('dap.ui.widgets').hover()
end)
vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end)
vim.keymap.set('n', '<Leader>dt', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.threads)
end)

keymap('n', '<leader>dr', "<CMD>lua require'dap'.repl.toggle()<CR>", opts)
keymap('n', '<leader>db', "<CMD>lua require'dap'.toggle_breakpoint()<CR>", opts)


keymap('n', '<leader>g', "<CMD>Neogit<cr>", opts)
-- keymap('n', '<leader>e', "<CMD>new<BAR>e.<cr>", opts)
vim.keymap.set('n', '<leader>e', function()
  -- if vim.api.nvim_buf_get_name(0) == "" then
  vim.cmd.edit('.')
  -- else
  --   vim.cmd.new()
  --   vim.cmd.edit('.')
  -- end
end, { desc = "Browse directory" })
-- keymap('n', '<leader>E', "<CMD>execute 'new | e ' . expand('%:h')<CR>", opts)
keymap('n', '<leader>E', "<CMD>execute 'e ' . expand('%:h')<CR>", opts)
vim.keymap.set('n', '<leader>h',
  function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 }) end, opts)

keymap('n', '<C-]>', "<C-]>zz", opts)
keymap('n', '<C-W>m', "<C-W>_<C-W>|", opts)

vim.keymap.set('n', ']f', '<CMD>TSTextobjectGotoNextStart @function.outer<CR>')
vim.keymap.set('n', ']]f', '<CMD>TSTextobjectGotoNextStart @function.inner<CR>')
vim.keymap.set('n', '[f', '<CMD>TSTextobjectGotoPreviousStart @function.outer<CR>')
vim.keymap.set('n', '[[f', '<CMD>TSTextobjectGotoPreviousStart @function.inner<CR>')

vim.keymap.set('n', ']a', '<CMD>TSTextobjectGotoNextStart @parameter.inner<CR>')
vim.keymap.set('n', ']]a', '<CMD>TSTextobjectGotoNextStart @parameter.outer<CR>')
vim.keymap.set('n', '[a', '<CMD>TSTextobjectGotoPreviousStart @parameter.inner<CR>')
vim.keymap.set('n', '[[a', '<CMD>TSTextobjectGotoPreviousStart @parameter.outer<CR>')

vim.keymap.set('t', '<C-\\>', '<C-\\><C-n>')

-- Neorg
vim.keymap.set('n', '<Leader>oc', '<CMD>Neorg capture<CR>', { silent = true })
vim.keymap.set('n', '<Leader>ot', '<CMD>Neorg toggle-concealer<CR>')
vim.keymap.set('n', '<a-TAB>', 'gt')
vim.keymap.set('n', '<a-S-TAB>', 'gT')

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

vim.keymap.set('n', '<Leader>q', toggle_quickfix)

-- Window management
vim.keymap.set('n', '<a-l>', '<C-w>l')
vim.keymap.set('n', '<a-h>', '<C-w>h')
vim.keymap.set('n', '<a-j>', '<C-w>j')
vim.keymap.set('n', '<a-k>', '<C-w>k')
vim.keymap.set('n', '<a-->', '<C-w>-')
vim.keymap.set('n', '<a-S-=>', '<C-w>+')
vim.keymap.set('n', '<a-=>', '<C-w>=')
vim.keymap.set('n', '<a-b>', '<C-w>b')
vim.keymap.set('n', '<a-t>', '<C-w>t')
vim.keymap.set('n', '<a-L>', '<C-w>L')
vim.keymap.set('n', '<a-H>', '<C-w>H')
vim.keymap.set('n', '<a-J>', '<C-w>J')
vim.keymap.set('n', '<a-K>', '<C-w>K')

local Terminal = require('toggleterm.terminal').Terminal

local trip_is_running = false
local _Toggle_activity_term
local ui_activity_is_running = false
local ui_cart_is_running = false


local activityterm = Terminal:new({
  -- cmd = "sbtn \"reload; project activity-web; run 9002\"",
  cmd = "bloop run activity-web --main play.core.server.ProdServerStart",
  display_name = "activity",
  close_on_exit = false,
  env = {
    _JAVA_OPTIONS = "-Dhttp.port=9002 -Dap.assets.url.base=/activity"
  },
  on_stdout = function(terminal, job, data, name)
    for _, line in ipairs(data) do
      -- if line:match("Caused by: java.sql.SQLException: Attempting to obtain a connection from a pool that has already been shutdown.") then
      --   terminal:shutdown()
      --   Toggle_activity_term()
      -- end
    end
  end
}
)

local tripterm = Terminal:new({
  cmd = "sbt \"project trip-web; run 9013\"",
  dir = "/Users/brian/Development/trip",
  display_name = "trip",
  hidden = false,
  on_create = function(terminal) trip_is_running = true end,
  on_exit = function(terminal) trip_is_running = false end,
  on_stdout = function(terminal, job, data, name)
    for _, line in ipairs(data) do
      if line:match("Caused by: java.sql.SQLException: Attempting to obtain a connection from a pool that has already been shutdown.") then
        terminal:shutdown()
      end
    end
  end
}
)

local uiactivityterm = Terminal:new({
  cmd = "yarn start -p activity",
  dir = "/Users/brian/Development/ui-tsttravel",
  display_name = "ui activity",
  hidden = false,
  on_create = function(terminal) ui_activity_is_running = true end,
  on_exit = function(terminal) ui_activity_is_running = false end,
  on_stdout = function(terminal, job, data, name) end
}
)

local uicartterm = Terminal:new({
  cmd = "yarn start -p cart",
  dir = "/Users/brian/Development/ui-tsttravel",
  display_name = "ui cart",
  hidden = false,
  on_create = function(terminal) ui_cart_is_running = true end,
  on_exit = function(terminal) ui_cart_is_running = false end,
  on_stdout = function(terminal, job, data, name) end
}
)

_Toggle_activity_term = function()
  if not ui_cart_is_running then
    uicartterm:spawn()
  end
  if not ui_activity_is_running then
    uiactivityterm:spawn()
  end
  if not trip_is_running then
    tripterm:spawn()
  end
  activityterm:toggle()
end

local control = Terminal:new({ cmd = "w3m http://127.0.0.1/control", direction = "float" })

function _Control_toggle()
  control:toggle()
end

vim.keymap.set('n', '<F12>', function() _Toggle_activity_term() end)

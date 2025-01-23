local opts = { noremap = true, silent = true }

local with_opts = function(opts)
  local return_opts = { noremap = true, silent = true }
  for k, v in pairs(opts) do
    return_opts[k] = v
  end
  return return_opts
end

local with_desc = function(desc)
  return with_opts({ desc = desc })
end

vim.keymap.set('n', ']q', ':silent cnext<CR>', with_desc("Next quickfix item"))
vim.keymap.set('n', '[q', ':silent cprevious<CR>', with_desc("Previous quickfix item"))
vim.keymap.set('n', '<Leader>bb', '<CMD>FzfLua buffers<CR>', with_desc("List Buffers"))
vim.keymap.set('n', '<C-b>', '<CMD>FzfLua buffers<CR>', with_desc("List Buffers"))
vim.keymap.set({ 'n', 'v' }, '<Leader><Space>', function()
  local fzf = require('fzf-lua')
  fzf.commands({
    actions = {
      ["enter"] = {
        fn = function(cmd)
          vim.notify(table.concat(cmd))
          vim.schedule(function() vim.cmd(table.concat(cmd)) end)
        end,
        -- exec_silent = true
      }
    }
  })
end, with_desc("Command pallete"))
vim.keymap.set('n', 'L', 'zL')
vim.keymap.set('n', 'H', 'zH')
local dap = require('dap')
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = "Continue" })
vim.keymap.set('n', '<F6>', function() require('dap').step_into() end, { desc = "Step Into" })
vim.keymap.set('n', '<F7>', function() require('dap').step_over() end, { desc = "Step Over" })
vim.keymap.set('n', '<F8>', function() require('dap').step_out() end, { desc = "Step Out" })
vim.keymap.set('n', '<F10>', dap.run_to_cursor, { desc = "Run To Cursor" })
-- vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>dB', function() require('dap').set_breakpoint() end, { desc = 'DAP Set Breakpoint' })
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

vim.keymap.set('n', '<leader>dr', "<CMD>lua require'dap'.repl.toggle()<CR>", opts)
vim.keymap.set('n', '<leader>db', "<CMD>lua require'dap'.toggle_breakpoint()<CR>", opts)

vim.keymap.set('n', '<leader>p', '<CMD>Projects<CR>', with_desc("Projects"))

vim.keymap.set('n', '<leader>n', "<CMD>Neorg<CR>", with_desc("Neorg"))
vim.keymap.set('n', '<leader>g', "<CMD>Neogit<CR>", with_desc("Neogit"))
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
vim.keymap.set('n', '<leader>E', "<CMD>execute 'e ' . expand('%:h')<CR>", with_desc("Open current of buffer"))

vim.keymap.set('n', '<C-]>', "<C-]>zz", opts)
vim.keymap.set('n', '<C-W>m', "<C-W>_<C-W>|", opts)

vim.keymap.set('n', ']f', '<CMD>TSTextobjectGotoNextStart @function.outer<CR>')
vim.keymap.set('n', ']]f', '<CMD>TSTextobjectGotoNextStart @function.inner<CR>')
vim.keymap.set('n', '[f', '<CMD>TSTextobjectGotoPreviousStart @function.outer<CR>')
vim.keymap.set('n', '[[f', '<CMD>TSTextobjectGotoPreviousStart @function.inner<CR>')

vim.keymap.set('n', ']a', '<CMD>TSTextobjectGotoNextStart @parameter.inner<CR>')
vim.keymap.set('n', ']]a', '<CMD>TSTextobjectGotoNextStart @parameter.outer<CR>')
vim.keymap.set('n', '[a', '<CMD>TSTextobjectGotoPreviousStart @parameter.inner<CR>')
vim.keymap.set('n', '[[a', '<CMD>TSTextobjectGotoPreviousStart @parameter.outer<CR>')

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

-- Window management
vim.keymap.set('n', '<a-l>', '<CMD>wincmd l<CR>')
vim.keymap.set('n', '<a-h>', '<CMD>wincmd h<CR>')
vim.keymap.set('n', '<a-j>', '<CMD>wincmd j<CR>')
vim.keymap.set('n', '<a-k>', '<CMD>wincmd k<CR>')
vim.keymap.set('n', '<a-->', '<CMD>wincmd -<CR>')
vim.keymap.set('n', '<a-S-=>', '<CMD>wincmd +<CR>')
vim.keymap.set('n', '<a-=>', '<CMD>wincmd =<CR>')
vim.keymap.set('n', '<a-b>', '<CMD>wincmd b<CR>')
vim.keymap.set('n', '<a-p>', '<CMD>wincmd p<CR>')
vim.keymap.set('n', '<a-w>', '<CMD>wincmd w<CR>')
vim.keymap.set('n', '<a-t>', '<CMD>wincmd t<CR>')
vim.keymap.set('n', '<a-L>', '<CMD>wincmd L<CR>')
vim.keymap.set('n', '<a-H>', '<CMD>wincmd H<CR>')
vim.keymap.set('n', '<a-J>', '<CMD>wincmd J<CR>')
vim.keymap.set('n', '<a-K>', '<CMD>wincmd K<CR>')

---- luasnip
local ls = require("luasnip")

vim.keymap.set({ "i" }, "<C-L>", function() ls.expand() end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-J>", function() ls.jump(1) end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-K>", function() ls.jump(-1) end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-E>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, { silent = true })


--- terminal
-- vim.keymap.set('t', '<esc>', '<c-\\><c-n>', { desc = "normal mode" })

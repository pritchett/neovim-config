local opt = vim.opt
local o = vim.o
local wo = vim.wo
local g = vim.g
-- local bo = vim.bo

-- Settings

g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.neo_tree_remove_legacy_commands = 1

opt.tabstop = 2
opt.number = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
-- opt.completeopt = { "menu", "preview", "longest","noselect" }
opt.completeopt = { "menuone", "longest", "noinsert", "noselect" }
opt.inccommand = 'nosplit'
opt.cmdheight = 0

-- --Global
o.swapfile = true
o.dir = '/tmp'
o.ignorecase = true
o.smartcase = true
o.laststatus = 3 -- The value of this option influences when the last window will have a status line
o.hlsearch = true
o.incsearch = true
o.scrolloff = 3
o.wrap = false
o.autochdir = false
-- o.magic = true
-- o.setsidescroll = 1 -- minimal number of columns to scroll horizontally
o.lazyredraw = true -- don't redraw while executing macros
o.list = true
o.background = 'dark'
o.termguicolors = true
o.cursorline = true
-- o.hidden = true -- don't unload a buffer when no longer shown in a window
o.splitright = true
o.confirm = true
o.undofile = true
o.undodir = '/tmp'
o.autoread = true
o.wildmode = 'full:longest'
o.virtualedit = 'block'
-- o.gdefault = true -- use the 'g' flag for ":substitute"
o.signcolumn = 'yes'
o.foldlevel = 2
vim.opt_global.shortmess:remove('F') -- don't give the file info when editing a file, like `:silent`
                                     -- was used for the command; note that this also affects messages
                                     -- from autocommands
                                     -- for nvim-metals
vim.opt_global.fillchars:append({ fold = ' ' })

-- -- Window
wo.number = true

g.catppuccin_flavour = "macchiato"

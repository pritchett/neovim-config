local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local pattern = [=[[%'%"%>%]%)%}%,]]=]
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local command_overrides = {
  ['Config'] = function()
    vim.ui.select({ "main", "plugins", "keymaps", "autocmds" }, { prompt = "Config" }, function(choice)
      if (choice == "main") then
        vim.cmd("Config")
      else
        vim.cmd("Config " .. choice)
      end
    end)
  end,
  ['Gitsigns'] = true,
  ['Lazy'] = function() vim.cmd('Lazy home') end
}

local command_action = function(prompt_bufnr)
  local selection = require('telescope.actions.state').get_selected_entry()
  if selection == nil then
    require('telescope.actions.utils').__warn_no_selection "builtin.commands"
    return
  end

  require('telescope.actions').close(prompt_bufnr)
  local val = selection.value
  local cmd = string.format([[:%s ]], val.name)

  local override = command_overrides[val.name]
  if type(override) == "function" then
    override()
    return
  elseif override or val.nargs == "0" then
    local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
    cmd = cmd .. cr
  end
  vim.cmd [[stopinsert]]
  vim.api.nvim_feedkeys(cmd, "nt", false)
end

-- Plugins
require("lazy").setup({

  -- {
  --   "tpope/vim-fugitive",
  --   dependencies = { 'tpope/vim-rhubarb' },
  --   cmd = "G"
  -- },

  {
    'mrcjkb/rustaceanvim',
    version = '^4', -- Recommended
    ft = { 'rust' },
  },

  "nvim-lua/plenary.nvim",

  "nvim-telescope/telescope-fzy-native.nvim",
  -- https://github.com/nvim-telescope/telescope.nvim
  "nvim-telescope/telescope-ui-select.nvim",
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          mappings = {
            i = { ['<C-h>'] = require('telescope.actions.layout').toggle_preview },
            n = { ['<C-h>'] = require('telescope.actions.layout').toggle_preview }
          }
        },
        pickers = {
          commands = {
            mappings = {
              i = { ['<CR>'] = command_action },
              n = { ['<CR>'] = command_action }
            }
          }

        },
        extensions = {
          ["fzy_native"] = {
            override_generic_sorter = false,
            override_file_sorter = true,
          },
          ["ui-select"] = {
            require("telescope.themes").get_ivy({}),
          },
        },
      })
      telescope.load_extension("fzy_native")
      telescope.load_extension("ui-select")
      telescope.load_extension('hoogle')
    end,
  },

  {
    "scalameta/nvim-metals",
    dependencies = "nvim-lua/plenary.nvim",
    ft = { "scala", "sbt" }
  },

  {
    "williamboman/mason.nvim",
    opts = {}
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "williamboman/mason.nvim",
    opts = {}
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = "williamboman/mason-lspconfig.nvim",
    config = function()
      require("user.plugins.config.lspconfig").config()
    end,
  },

  "nvim-neotest/nvim-nio",

  "mfussenegger/nvim-dap",
  "theHamsta/nvim-dap-virtual-text",

  { "rcarriga/nvim-dap-ui",    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },

  {
    "folke/neodev.nvim",
    opts = {
      library = { plugins = { "nvim-dap-ui" }, types = true },
    }
  },

  -- Snippets
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",

  {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
    end,
    cmd = "Notifications"
  },

  -- Neat idea, but buggy
  -- use {
  --   'mrded/nvim-lsp-notify',
  --   config = function()
  --     require('lsp-notify').setup({})
  --   end
  -- }
  --
  "rcarriga/cmp-dap",

  "hrsh7th/cmp-nvim-lsp-signature-help",
  -- Completions
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        mapping = {
          ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
          ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-f>"] = cmp.mapping({
            i = cmp.mapping.scroll_docs(4), -- { 'i', 'c' },
            c = cmp.mapping.abort(),
          }),
          ["<C-c>"] = cmp.mapping(cmp.mapping.abort()),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
          ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ['<C-h>'] = function()
            if cmp.visible_docs() then
              cmp.close_docs()
            else
              cmp.open_docs()
            end
          end,
          ["<CR>"] = cmp.mapping.confirm({
            select = false,
            behavior = cmp.ConfirmBehavior.Insert,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<TAB>"] = cmp.mapping(function(fallback)
            local entry = cmp.get_active_entry()
            if cmp.visible() and not entry then
              cmp.confirm({
                select = true,
                behavior = cmp.ConfirmBehavior.Insert
              })
            else
              fallback()
            end
          end),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp_signature_help" },
          { name = "nvim_lsp" },
          { name = "luasnip" }, -- For luasnip users.
          { name = "buffer" },
          { name = "neorg" },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, item)
            local kind_icons = {
              Text = "",
              Method = "󰆧",
              Function = "󰊕",
              Constructor = "",
              Field = "󰇽",
              Variable = "󰂡",
              Class = "󰠱",
              Interface = "",
              Module = "",
              Property = "󰜢",
              Unit = "",
              Value = "󰎠",
              Enum = "",
              Keyword = "󰌋",
              Snippet = "",
              Color = "󰏘",
              File = "󰈙",
              Reference = "",
              Folder = "󰉋",
              EnumMember = "",
              Constant = "󰏿",
              Struct = "",
              Event = "",
              Operator = "󰆕",
              TypeParameter = "󰅲",
            }
            item.kind = string.format("%s", kind_icons[item.kind])
            item.menu = ({
              nvim_lsp = "[LSP]",
              vsnip = "[Snip]",
              buffer = "[Buffer]",
              neorg = "[Neorg]",
            })[entry.source.name]
            return item
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        preselect = cmp.PreselectMode.None, --  Fixes super annoying behavior of auto selecting what appears to be a random item in the middle of the completion list
        experimental = { ghost_text = true },
        native_menu = true,
      })

      -- cmp.setup.filetype('mysql', {
      --   { name = "vim-dadbod-completion" },
      --   { name = "buffer" }
      -- })

      cmp.setup.filetype({ 'sql', 'mysql', 'psql', 'postgresql' }, {
        sources = {
          { name = "vim-dadbod-completion" },
          { name = "buffer" }
        }
      })

      require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = {
          { name = "dap" },
        },
      })

      local compare = require('cmp').config.compare
      cmp.setup.filetype({ 'scala', 'sbt', 'java' },
        {
          sorting = {
            priority_weight = 2,
            comparators = {
              compare.offset,    -- we still want offset to be higher to order after 3rd letter
              compare.score,     -- same as above
              compare.sort_text, -- add higher precedence for sort_text, it must be above `kind`
              compare.recently_used,
              compare.kind,
              compare.length,
              compare.order,
            },
          },

        })

      --    cmp.setup.cmdline(':', {
      --      sources = {
      --        { name = 'cmdline' },
      --        { name = 'path' }
      --      },
      --      formatting = {
      --          fields = { "abbr" }
      --        }
      --      })

      -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      --    cmp.setup.cmdline('/', {
      --      sources = {
      --        { name = 'buffer' }
      --      },
      --      formatting = {
      --          fields = { "abbr" }
      --        }
      --    })

      --cmp.setup.cmdline('?', {
      --  sources = {
      --    { name = 'buffer' }
      --  },
      --  formatting = {
      --      fields = { "abbr" }
      --    }
      --})
    end,
  },
  "hrsh7th/cmp-nvim-lsp",
  --  use { 'hrsh7th/cmp-cmdline' }
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-buffer",

  -- LSP UI
  { "RishabhRD/nvim-lsputils", dependencies = { { "RishabhRD/popfix" } } },
  "ray-x/lsp_signature.nvim",

  --Colors
  "catppuccin/nvim",

  "nvim-tree/nvim-web-devicons",

  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },

  { dir = "~/Development/neorg-templates" },

  "pritchett/neorg-capture",

  {
    "nvim-neorg/neorg",
    dependencies = { "luarocks.nvim" },
    ft = "norg",
    cmd = "Neorg",
    opts = {
      load = {
        ["core.defaults"] = {},  -- Loads default behaviour
        ["core.concealer"] = {}, -- Adds pretty icons to your documents
        ["core.completion"] = { config = { engine = "nvim-cmp" } },
        ["core.export"] = {},
        ["core.dirman"] = { -- Manages Neorg workspaces
          config = {
            default_workspace = "notes",
            workspaces = {
              notes = "~/notes",
            },
          },
        },
        ["external.templates"] = {},
        ["external.capture"] = {
          config = {
            templates = {
              {
                description = "Standup",
                name = "standup",
                file = "/Users/brian/notes/standup.norg",
                datetree = true,
                after_save = function(bufnr, _)
                  local neorg = require("neorg.core")
                  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                  local mod_lines = {}
                  for _, line in ipairs(lines) do
                    local new_line = line:gsub("^%s*-", "")
                    new_line = new_line:gsub("^%s*%*%*%*%*", "- ")
                    table.insert(mod_lines, new_line)
                  end
                  local buf = vim.api.nvim_create_buf(false, true)
                  vim.api.nvim_buf_set_lines(buf, 0, -1, false, mod_lines)
                  local md = neorg.modules.loaded_modules["core.export"].public.export(buf, "markdown")
                  vim.fn.setreg("+", md)
                end
              },
              {
                description = "Nvim configuration idea",
                name = "nvim-ideas",
                file = "/Users/brian/notes/nvim.norg",
                headline = "Nvim"
              },
              {
                description = "Accomplishment",
                name = "accomplishments",
                file = "/Users/brian/notes/accomplishments.norg",
                headline = "Accomplishments"
              }
            },
          },
        },
      },
    },
    run = ":Neorg sync-parsers",
  },


  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    opts = {
      extensions = { "quickfix", "fugitive", "nvim-dap-ui", "lazy", "mason", "oil", "toggleterm" },
      options = {
        disabled_filetypes = {
          "netrw",
          "dapui_stacks",
          "dapui_breakpoints",
          "dapui_watches",
          "dapui_scopes",
          "NeogitPopup",
          "NeogitStatus",
          "NeogitLogView",
          "NeogitGitCommandHistory",
          "NeogitCommitSelectView",
          "NeogitConsole",
          "NeogitCommitMessage",
          "NeogitBranchSelectView",
          "NeogitCommitView",
          "qf",
          "git",
          "neo-tree",
          "packer",
          "vim",
          "dbui"
        },
        ignore_focus = { "neo-tree" },
        theme = "catppuccin",
        icons_enabled = true,
        globalstatus = true,
      },
      sections = {
        lualine_a = { "branch" },
        lualine_b = { "diff" },
        lualine_c = { "diagnostics" },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          {
            "g:metals_bsp_status",
            cond = function()
              local ft = vim.o.filetype
              return ft == 'scala' or ft == "sbt"
            end
          }
        }
      },
      winbar = {
        lualine_a = {
          { 'mode' },
          {
            "b:terminal_mode",
            cond = function()
              return vim.bo.buftype and vim.bo.buftype == "terminal"
            end,
            color = function()
              if (vim.b.terminal_mode == 'NORMAL') then
                return "lualine_a_normal"
              end
              if (vim.b.terminal_mode == 'INSERT') then
                return "lualine_a_insert"
              end
              if (vim.b.terminal_mode == 'VISUAL') then
                return "lualine_a_visual"
              end
              if (vim.b.terminal_mode == 'V-LINE') then
                return "lualine_a_v_line"
              end

              return { bg = "blue", fg = "black", gui = "bold" }
            end
          },
        },
        lualine_b = {
          {
            "filename",
            cond = function()
              return vim.o.filetype ~= 'oil'
            end
          },
          {
            "bufname",
            fmt = function(str)
              return str:gsub("oil://", "")
            end,
            cond = function()
              return vim.o.filetype == 'oil'
            end
          }
        },
        lualine_c = {},
        lualine_x = { "searchcount", "encoding", "fileformat", "filetype" },
        lualine_y = {
          {
            "progress",
            disabled_buftypes = { "terminal" },
            cond = function()
              local is_term = vim.bo.buftype and vim.bo.buftype == "terminal"
              if (is_term) then return false end
              return true
            end
          }
        },
        lualine_z = {
          {
            "location",
            disabled_buftypes = { "terminal" },
            cond = function()
              local is_term = vim.bo.buftype and vim.bo.buftype == "terminal"
              if (is_term) then return false end
              return true
            end
          },
        },
      },
      inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    }
  },

  "mrjones2014/nvim-ts-rainbow",
  "nvim-treesitter/nvim-treesitter-textobjects",

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- One of "all", "maintained" (parsers with maintainers), or a list of languages
        ensure_installed = "all",
        modules = {},
        ignore_install = {},
        auto_install = false,

        -- Install languages synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- List of parsers to ignore installing
        -- ignore_install = { "javascript" },

        highlight = {
          -- `false` will disable the whole extension
          enable = true,

          -- list of language that will be disabled
          -- disable = { "c", "rust" },

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          -- additional_vim_regex_highlighting = true,
          additional_vim_regex_highlighting = false,
        },
        rainbow = {
          enable = true,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            node_incremental = "v",
            node_decremental = "V",
          }
        },
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              -- You can optionally set descriptions to the mappings (used in the desc parameter of
              -- nvim_buf_set_keymap) which plugins like which-key display
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              -- You can also use captures from other query groups like `locals.scm`
              ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
              ["aP"] = "@parameter.outer",
              ["iP"] = "@parameter.inner"
            },
            lsp_interop = {
              enable = true,
              border = "none",
              floating_preview_opts = {},
              peek_definition_code = {
                ["<leader>df"] = "@function.outer",
                ["<leader>dF"] = "@class.outer",
              },
            }
          }
        }
      })
    end
  },

  {
    "nvim-treesitter/playground",
    build = ":TSUpdate",
  },

  {
    'j-hui/fidget.nvim',
    opts = {}
  },

  {
    "kosayoda/nvim-lightbulb",
    opts = {
      autocmd = {
        enabled = true,
      },
      ignore = {
        -- Ignore code actions without a `kind` like refactor.rewrite, quickfix.
        actions_without_kind = true,
      },
    }
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      scope = {
        show_start = false,
        show_end = false,
      },
    }
  },

  "milisims/nvim-luaref",

  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {}
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      disable_filetype = { "TelescopePrompt", "vim" },
      fast_wrap = {},
      -- check_ts = true,
      -- ts_config = {
      --   lua = { 'string' }, -- it will not add a pair on that treesitter node
      --   javascript = { 'template_string' },
      --   java = false,   -- don't check treesitter on java
      -- }
    }
  },

  -- {
  --   "numToStr/Comment.nvim",
  --   opts = {}
  -- },

  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    opts = {}
  },

  {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    opts = {}
    -- config = function()
    --   require("neogit").setup({
    --     -- integrations = {
    --     -- telescope = , -- If these are set to true, it disables the integration. Great api.
    --     -- diffview = true,
    --     -- },
    --   })
    -- end,
  },

  {
    "kevinhwang91/nvim-bqf",
    ft = "qf"
  },

  "rafcamlet/nvim-luapad",

  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },

  {
    "stevearc/oil.nvim",
    opts = {
      skip_confirm_for_simple_edits = true,
      lsp_file_methods = {
        -- Time to wait for LSP file operations to complete before skipping
        timeout_ms = 1000,
        -- Set to true to autosave buffers that are updated with LSP willRenameFiles
        -- Set to "unmodified" to only save unmodified buffers
        autosave_changes = "unmodified",
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" }
  },

  'camilledejoye/nvim-lsp-selection-range',

  -- Haskell
  {
    'MrcJkb/haskell-tools.nvim',
    config = function()
      vim.g.haskell_tools = {
        ---@type ToolsOpts
        tools = {
          repl = {
            handler = "toggleterm"
          }
        },
        ---@type HaskellLspClientOpts
        -- hls = {
        -- on_attach = require("user.lsp").on_attach
        -- },
      }
    end
  },

  'luc-tielen/telescope_hoogle',

  {
    "akinsho/toggleterm.nvim",
    opts = {
      open_mapping = [[<leader>t]],
      hide_numbers = true,
      insert_mappings = false,
      terminal_mappings = false
    },
    config = true
  },

  -- {
  --   "kndndrj/nvim-dbee",
  --   dependencies = { "MunifTanjim/nui.nvim", },
  --   build = function()
  --     -- Install tries to automatically detect the install method.
  --     -- if it fails, try calling it with one of these parameters:
  --     --    "curl", "wget", "bitsadmin", "go"
  --     require("dbee").install()
  --   end,
  --   lazy = true,
  --   cmd = "Dbee",
  --   config = function()
  --     require('dbee').setup {
  --       lazy = true,
  --       sources = {
  --         require("dbee.sources").MemorySource:new({
  --           {
  --             -- id = "optional_identifier" -- only mandatory if you edit a file by hand. IT'S YOUR JOB TO KEEP THESE UNIQUE!
  --             name = "cdev mysql",
  --             type = "mysql", -- type of database driver
  --             url = "travel:travel@tcp(nodes.nonprod.kube.tstllc.net:32114)/"
  --           },
  --           {
  --             -- id = "optional_identifier" -- only mandatory if you edit a file by hand. IT'S YOUR JOB TO KEEP THESE UNIQUE!
  --             name = "local mysql",
  --             type = "mysql", -- type of database driver
  --             url = "root@tcp(localhost:3306)/"
  --           },
  --           {
  --             -- id = "optional_identifier" -- only mandatory if you edit a file by hand. IT'S YOUR JOB TO KEEP THESE UNIQUE!
  --             name = "production mysql",
  --             type = "mysql", -- type of database driver
  --             url = "v-ldap-Brian-prod-aws-d-LSWTNoOM:mPZSJQe1-I6Yt6XmLekF@tcp(mysqlread.prod.infra.tstllc.net:3306)/"
  --           },
  --           {
  --             -- id = "optional_identifier" -- only mandatory if you edit a file by hand. IT'S YOUR JOB TO KEEP THESE UNIQUE!
  --             name = "local redis",
  --             type = "redis", -- type of database driver
  --             url = "localhost:6379"
  --           },
  --           {
  --             -- id = "optional_identifier" -- only mandatory if you edit a file by hand. IT'S YOUR JOB TO KEEP THESE UNIQUE!
  --             name = "cstaging mongo",
  --             type = "mongo", -- type of database driver
  --             url = "mongodb://nodes.nonprod.kube.tstllc.net:32117/?tls=true"
  --           },
  --         })
  --
  --       }
  --     }
  --   end
  -- },

  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod',                     lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },

  -- {
  --   "nvim-neotest/neotest",
  --   dependencies = {
  --     "nvim-neotest/nvim-nio",
  --     "nvim-lua/plenary.nvim",
  --     "antoinemadec/FixCursorHold.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --     "stevanmilic/neotest-scala",
  --   },
  --   config = function()
  --     require("neotest").setup({
  --       adapters = {
  --         require("neotest-scala")({
  --           framework = "scalatest"
  --         }),
  --       }
  --     })
  --   end
  -- },

  {
    'rmagatti/auto-session',
    dependencies = {
      'nvim-telescope/telescope.nvim', -- Only needed if you want to use sesssion lens
    },
    config = function()
      require('auto-session').setup({
        auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
        auto_session_use_git_branch = true
      })
    end,
  },

  -- "yioneko/nvim-vtsls"
}



-- {
--   dev = {
--     path = "~/Development/",
--     -- patterns = { "pritchett", "NeogitOrg" }
--     patterns = { "pritchett" }
--   },
--   diff = {
--     cmd = "diffview.nvim"
--   }
-- }
)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

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

-- Plugins
require("lazy").setup({

    "tpope/vim-fugitive",

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
          extensions = {
            ["fzy_native"] = {
              override_generic_sorter = false,
              override_file_sorter = true,
            },
            ["ui-select"] = {
              require("telescope.themes").get_cursor({}),
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
      end
    },

    -- Neat idea, but buggy
    -- use {
    --   'mrded/nvim-lsp-notify',
    --   config = function()
    --     require('lsp-notify').setup({})
    --   end
    -- }

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
            ["<CR>"] = cmp.mapping.confirm({
              select = false,
              behavior = cmp.ConfirmBehavior.Replace
            }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            ["<TAB>"] = cmp.mapping(function(fallback)
              local entry = cmp.get_active_entry()
              if cmp.visible() and not entry then
                cmp.confirm({
                  select = true,
                  behavior = cmp.ConfirmBehavior.Replace
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
        extensions = { "quickfix", "fugitive", "nvim-dap-ui", "neo-tree" },
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
            "vim"
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
          lualine_x = { '%S' },
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
            {
              'mode',
              cond = function()
                local is_not_dbee_buf = function()
                  local bufname = vim.fn.bufname()
                  local bufnames = { "dbee-drawer", "dbee-call-log" }

                  for _, bname in ipairs(bufnames) do
                    if bname == bufname then
                      return false
                    end
                  end

                  return true
                end

                local is_term = vim.bo.buftype and vim.bo.buftype == "terminal"

                return not is_term and is_not_dbee_buf()
              end
            },
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
              -- cond = function() return is_not_dbee_buf() and is_not_oil_buf() end
              cond = function()
                local bufname = vim.fn.bufname()
                local bufnames = { "dbee-drawer", "dbee-call-log" }

                for _, bname in ipairs(bufnames) do
                  if bname == bufname then
                    return false
                  end
                end

                return true
              end
            }
          },
          lualine_z = {
            {
              "location",
              disabled_buftypes = { "terminal" },
              cond = function()
                local bufname = vim.fn.bufname()
                local bufnames = { "dbee-drawer", "dbee-call-log" }

                for _, bname in ipairs(bufnames) do
                  if bname == bufname then
                    return false
                  end
                end

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
        })
      end
    },

    {
      "nvim-treesitter/playground",
      build = ":TSUpdate",
    },

    "nvim-treesitter/nvim-treesitter-textobjects",

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
          actions_without_kind = false,
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
      opts = {
        disable_filetype = { "TelescopePrompt", "vim" },
        fast_wrap = {},
      }
    },

    {
      "numToStr/Comment.nvim",
      opts = {}
    },

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

    { "kevinhwang91/nvim-bqf",              ft = "qf" },

    "rafcamlet/nvim-luapad",

    {
      "stevearc/oil.nvim",
      opts = {},
      dependencies = { "nvim-tree/nvim-web-devicons" }
    },

    'camilledejoye/nvim-lsp-selection-range',

    -- Haskell
    {
      'MrcJkb/haskell-tools.nvim',
      config = function()
        vim.g.haskell_tools = {
          -- @type ToolsOpts
          tools = {
            repl = {
              handler = "toggleterm"
            }
          },
          hls = {
            on_attach = require("user.lsp").on_attach
          },
        }
      end
    },

    'luc-tielen/telescope_hoogle',

    {
      "akinsho/toggleterm.nvim",
      opts = {
        open_mapping = [[<leader>t]],
        insert_mappings = false,
        terminal_mappings = false
      }
    },

    {
      "kndndrj/nvim-dbee",
      dependencies = { "MunifTanjim/nui.nvim", },
      build = function()
        -- Install tries to automatically detect the install method.
        -- if it fails, try calling it with one of these parameters:
        --    "curl", "wget", "bitsadmin", "go"
        require("dbee").install()
      end,
      -- config = function()
      --   require("dbee").setup(
      opts = {
        lazy = true,
        sources = {
          require("dbee.sources").MemorySource:new({
            {
              -- id = "optional_identifier" -- only mandatory if you edit a file by hand. IT'S YOUR JOB TO KEEP THESE UNIQUE!
              name = "cdev mysql",
              type = "mysql", -- type of database driver
              url = "travel:travel@tcp(nodes.nonprod.kube.tstllc.net:32114)/"
            },
            {
              -- id = "optional_identifier" -- only mandatory if you edit a file by hand. IT'S YOUR JOB TO KEEP THESE UNIQUE!
              name = "local mysql",
              type = "mysql", -- type of database driver
              url = "root@tcp(localhost:3306)/"
            },
            {
              -- id = "optional_identifier" -- only mandatory if you edit a file by hand. IT'S YOUR JOB TO KEEP THESE UNIQUE!
              name = "production mysql",
              type = "mysql", -- type of database driver
              url = "v-ldap-Brian-prod-aws-d-LSWTNoOM:mPZSJQe1-I6Yt6XmLekF@tcp(mysqlread.prod.infra.tstllc.net:3306)/"
            },
            {
              -- id = "optional_identifier" -- only mandatory if you edit a file by hand. IT'S YOUR JOB TO KEEP THESE UNIQUE!
              name = "local redis",
              type = "redis", -- type of database driver
              url = "localhost:6379"
            },
            {
              -- id = "optional_identifier" -- only mandatory if you edit a file by hand. IT'S YOUR JOB TO KEEP THESE UNIQUE!
              name = "cstaging mongo",
              type = "mongo", -- type of database driver
              url = "mongodb://nodes.nonprod.kube.tstllc.net:32117/?tls=true"
            },
          })

        }
      }
    }
  },
  {
    dev = {
      path = "~/Development/",
      patterns = { "pritchett" }
    },
    diff = {
      cmd = "diffview.nvim"
    }
  })

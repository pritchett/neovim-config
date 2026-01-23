return {
   "hrsh7th/nvim-cmp",

   event = "InsertEnter",
   opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
         name = "lazydev",
         group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
   end,
   config = function()
      local cmp = require("cmp")
      cmp.setup({
         snippet = {
            expand = function(args)
               require("luasnip").lsp_expand(args.body)
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
            -- ["<C-c>"] = cmp.mapping(cmp.mapping.abort()),
            ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
            ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
            ["<C-c>"] = cmp.mapping({
               i = cmp.mapping.abort(),
               c = cmp.mapping.close(),
            }),
            ["<C-h>"] = function()
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
                     behavior = cmp.ConfirmBehavior.Insert,
                  })
               else
                  fallback()
               end
            end),
         },
         sources = cmp.config.sources({
            { name = "nvim_lsp_signature_help" },
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "neorg" },
            { name = "conjure" },
            {
               name = "omni",
               option = {
                  disable_omnifuncs = { "v:lua.vim.lsp.omnifunc" },
               },
            },
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
                  luasnip = "[Snip]",
                  buffer = "[Buffer]",
                  neorg = "[Neorg]",
                  ["vim-dadbod-completion"] = "[DB]",
               })[entry.source.name]
               return item
            end,
         },
         window = {
            completion = cmp.config.window.bordered(),
            -- documentation = cmp.config.window.bordered(),
         },
         preselect = cmp.PreselectMode.None, --  Fixes super annoying behavior of auto selecting what appears to be a random item in the middle of the completion list
         experimental = { ghost_text = false },
         native_menu = true,
      })

      cmp.setup.filetype({ "sql", "mysql", "psql", "postgresql" }, {
         sources = {
            { name = "vim-dadbod-completion" },
            { name = "buffer" },
         },
      })

      require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
         sources = {
            { name = "dap" },
         },
      })

      local compare = require("cmp").config.compare
      cmp.setup.filetype({ "scala", "sbt", "java" }, {
         sorting = {
            priority_weight = 2,
            comparators = {
               compare.offset, -- we still want offset to be higher to order after 3rd letter
               compare.score, -- same as above
               compare.sort_text, -- add higher precedence for sort_text, it must be above `kind`
               compare.recently_used,
               compare.kind,
               compare.length,
               compare.order,
            },
         },
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

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
}

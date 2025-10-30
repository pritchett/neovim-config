return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  config = function()
    -- USER = vim.fn.expand('$USER')

    -- local lspconfig = require('lspconfig')

    -- local runtime_path = vim.split(package.path, ';')
    -- table.insert(runtime_path, "lua/?.lua")
    -- table.insert(runtime_path, "lua/?/init.lua")

    -- lspconfig.util.default_config = vim.tbl_extend(
    --   'force',
    --   lspconfig.util.default_config,
    --   {
    --     capabilities = vim.tbl_deep_extend(
    --       "force",
    --       vim.lsp.protocol.make_client_capabilities(),
    --       -- returns configured operations if setup() was already called
    --       -- or default operations if not
    --       require 'lsp-file-operations'.default_capabilities()
    --     )
    --   }
    -- )

    -- lspconfig.lemminx.setup({})
    -- lspconfig.lua_ls.setup({})
    -- lspconfig.lua_ls.setup {
    --   settings = {
    --     Lua = {
    --       runtime = {
    --         -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
    --         version = 'LuaJIT',
    --       },
    --       diagnostics = {
    --         -- Get the language server to recognize the `vim` global
    --         globals = { 'vim' },
    --       },
    --       workspace = {
    --         -- Make the server aware of Neovim runtime files
    --         library = vim.api.nvim_get_runtime_file("", true),
    --         checkThirdParty = false,
    --       },
    --       -- Do not send telemetry data containing a randomized but unique identifier
    --       telemetry = {
    --         enable = false,
    --       },
    --       completion = {
    --         callSnippet = "Replace"
    --       }
    --     }
    --   }
    -- }


    -- lspconfig.hls.setup {
    --   filetypes = { 'haskell', 'lhaskell', 'cabal' },
    -- }

    -- lspconfig.graphql.setup {}

    -- lspconfig.bufls.setup {}

    -- lspconfig.ts_ls.setup {
    --   filetypes = { "javascript", "typescript", "typescriptreact", "typescript.tsx" },
    -- }

    -- require("lspconfig.configs").vtsls = require("vtsls").lspconfig -- set default server config, optional but recommended
    --
    -- lspconfig.vtsls.setup({})

    -- lspconfig.clangd.setup {}

    -- local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- capabilities.textDocument.completion.completionItem.snippetSupport = true
    -- lspconfig.jsonls.setup {
    --   capabilities = capabilities
    -- }
    -- lspconfig.jq.setup {
    -- }

    -- lspconfig.vimls.setup {}
  end,
  event = "VeryLazy",
}

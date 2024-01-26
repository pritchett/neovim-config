M = {}

function M.config()
  USER = vim.fn.expand('$USER')

  -- local sumneko_root_path = ""
  -- local sumneko_binary = ""
  local lspconfig = require('lspconfig')

  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")

  -- local library = vim.api.nvim_get_runtime_file("", true)
  -- table.insert(library, vim.fn.expand('$VIMRUNTIME/lua'))
  -- table.insert(library, vim.fn.expand('$VIMRUNTIME/lua/vim/lsp'))
  -- table.insert(library, USER .. "/.local/share/nvim/site/pack/packer/opt/*")
  -- table.insert(library, USER .. "/.local/share/nvim/site/pack/packer/start/*")
  --
  -- if vim.fn.has("mac") == 1 then
  --   sumneko_root_path = "/Users/" .. USER .. "/.cache/nvim/lua-language-server"
  --   sumneko_binary = "/Users/" .. USER .. "/.cache/nvim/lua-language-server/bin/lua-language-server"
  -- elseif vim.fn.has("unix") == 1 then
  --   sumneko_root_path = "/home/" .. USER .. "/.cache/nvim/lua-language-server"
  --   sumneko_binary = "/home/" .. USER .. "/.cache/nvim/lua-language-server/bin/lua-language-server"
  -- else
  --   print("Unsupported system for sumneko")
  -- end

  lspconfig.lua_ls.setup {
    on_attach = require("user.lsp").on_attach,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {'vim'},
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
        completion = {
          callSnippet = "Replace"
        }
      }
    }
  }
  -- lspconfig.sumneko_lua.setup {
  --   -- cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
  --   on_attach = require("user.lsp").on_attach,
  --   settings = {
  --     Lua = {
  --       runtime = {
  --         -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
  --         version = 'LuaJIT',
  --         -- Setup your lua path
  --         path = runtime_path
  --       },
  --       diagnostics = {
  --         -- Get the language server to recognize the `vim` global
  --         globals = {'vim'}
  --       },
  --       workspace = {
  --         -- Make the server aware of Neovim runtime files
  --         library = library
  --         --{
  --         --  [vim.fn.expand('$VIMRUNTIME/lua')] = true,
  --         --  [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
  --         --}
  --       },
  --     }
  --   }
  -- }


  -- lspconfig.hls.setup{
  --   on_attach = require("user.lsp").on_attach
  -- }

  lspconfig.graphql.setup {
    on_attach = require("user.lsp").on_attach
  }

  lspconfig.bufls.setup {
    on_attach = require("user.lsp").on_attach
  }

  lspconfig.tsserver.setup {
    on_attach = require("user.lsp").on_attach
  }


end

return M

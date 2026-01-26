-- [nfnl] after/lsp/lua_ls.fnl
return {settings = {Lua = {runtime = {version = "LuaJIT"}, diagnostics = {globals = {"vim"}}, workspace = {library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false}, telemetry = {enable = false}, completion = {callSnippet = "Replace"}}}}

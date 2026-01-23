return {
   "MrcJkb/haskell-tools.nvim",
   filetype = "haskell",
   init = function()
      vim.g.haskell_tools = {
         tools = {
            repl = {
               handler = "toggleterm",
            },
            hoogle = {
               -- "auto"|"telescope-local"|"telescope-web"|"browser"
               mode = "browser",
            },
         },
         -- hls = {
         -- on_attach = require("user.lsp").on_attach
         -- },
      }
   end,
}

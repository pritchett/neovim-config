return {
   "nvim-neorg/neorg",
   dependencies = { "luarocks.nvim", "nvim-neorg/lua-utils.nvim" },
   ft = "norg",
   cmd = "Neorg",
   opts = {
      load = {
         ["core.defaults"] = {}, -- Loads default behaviour
         ["core.presenter"] = { config = { zen_mode = "zen-mode" } },
         ["core.concealer"] = {}, -- Adds pretty icons to your documents
         ["core.completion"] = { config = { engine = "nvim-cmp" } },
         ["core.export"] = {},
         ["core.summary"] = {},
         ["core.text-objects"] = {},
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
                     end,
                  },
                  {
                     description = "Nvim configuration idea",
                     name = "nvim-ideas",
                     file = "/Users/brian/notes/nvim.norg",
                     headline = "Nvim",
                  },
                  {
                     description = "Accomplishment",
                     name = "accomplishments",
                     file = "/Users/brian/notes/accomplishments.norg",
                     headline = "Accomplishments",
                  },
               },
            },
         },
      },
   },
   run = ":Neorg sync-parsers",
   keys = {
      {
         "<leader>n",
         mode = { "n" },
         "<CMD>Neorg<CR>",
         desc = "Neorg",
      },
   },
}

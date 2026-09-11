return {
   "simifalaye/minibuffer.nvim",
   enabled = false,
   init = function()
      local minibuffer = require("minibuffer")

      vim.ui.select = require("minibuffer.builtin.ui_select")
      vim.ui.input = require("minibuffer.builtin.ui_input")

      vim.keymap.set("n", "<leader><CR>", function()
         minibuffer.resume(true)
      end)
   end,
}

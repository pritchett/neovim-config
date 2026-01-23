vim.cmd.inoreabbrev("<buffer> forall ∀")
vim.keymap.set("n", "<localleader>pr", "<CMD>split<CR><CMD>term npx spago run<CR>", { buffer = true })
vim.keymap.set("n", "<localleader>ps", function()
   vim.ui.input({ prompt = "Pursuit search: " }, function(input)
      if input == "" or input == nil then
         return
      end
      vim.cmd.split()
      vim.cmd.term("w3m 'https://pursuit.purescript.org/search?q=" .. input .. "'")
   end)
end, { buffer = true })
vim.keymap.set("n", "<localleader>pb", "<CMD>split<CR><CMD>term npx spago build<CR>", { buffer = true })

vim.keymap.set("n", "<localleader>r", "<CMD>split<BAR>wincmd J<BAR>term npx spago repl<CR>", { buffer = true })

vim.cmd("inoreabbrev <buffer> derivce derive")
vim.cmd("inoreabbrev <buffer> dervice derive")
vim.cmd("inoreabbrev <buffer> derivec derive")
vim.cmd("inoreabbrev <buffer> RIght Right")
vim.cmd("inoreabbrev <buffer> EIther Either")
vim.cmd("inoreabbrev <buffer> <_ <-")
vim.cmd("inoreabbrev <buffer> WRiter Writer")
vim.cmd("inoreabbrev <buffer> WRiterT WriterT")

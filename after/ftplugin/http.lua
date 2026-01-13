local ok, kulala = pcall(require, 'kulala')
if not ok then
  vim.notify("Could not set kulala keymaps. Is it installed?")
  return
end

vim.keymap.set({ 'n', 'v' }, '<localleader>ee', kulala.run, { desc = "Run http request", buffer = true })
vim.keymap.set({ 'n', 'v' }, '<localleader>er', kulala.replay, { desc = "Replay last http request", buffer = true })

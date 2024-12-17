return {
  "L3MON4D3/LuaSnip",
  version = "2.*",
  build = "make install_jsregexp",
  config = function()
    local ls = require('luasnip')
    local types = require('luasnip.util.types')
    local haskell_snippets = require('haskell-snippets').all
    ls.add_snippets('haskell', haskell_snippets, { key = 'haskell' })

    ls.setup({
      -- To enable auto expansin
      -- enable_autosnippets = true,
      -- Uncomment to enable visual snippets triggered using <c-x>
      -- store_selection_keys = '<c-x>',
      history = true,
      updateevents = "TextChanged,TextChangedI",
      ext_opts = {
        [types.choiceNode] = {
          active = {
            -- virt_text = { { } }
          }
        }
      }
    })
    -- LuaSnip key bindings
    -- vim.keymap.set({"i", "s"}, "<Tab>", function() if ls.expand_or_jumpable() then ls.expand_or_jump() else vim.api.nvim_input('<C-V><Tab>') end end, {silent = true})
    -- vim.keymap.set({"i", "s"}, "<S-Tab>", function() ls.jump(-1) end, {silent = true})
    -- vim.keymap.set({"i", "s"}, "<C-E>", function() if ls.choice_active() then ls.change_choice(1) end end, {silent = true})
  end,
  event = "InsertEnter"
}

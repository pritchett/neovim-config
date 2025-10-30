return {
  "L3MON4D3/LuaSnip",
  version = "2.*",
  build = "make install_jsregexp",
  config = function()
    local ls = require('luasnip')
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    local extras = require('luasnip.extras')
    local r = extras.rep
    local fmt = require('luasnip.extras.fmt').fmt
    local types = require('luasnip.util.types')
    local events = require('luasnip.util.events')
    local haskell_snippets = require('haskell-snippets').all
    ls.add_snippets('haskell', haskell_snippets, { key = 'haskell' })

    ls.add_snippets('scala', {
      s("newtype",
        fmt(
          [[
          type {} = {}.Type
          object {} extends Newtype[{}]
          ]], {
            i(1), r(1), r(1), i(2)
          }
        ),
        {
          callbacks = {
            [-1] = {
              [events.pre_expand] = function(node, event_args)
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                local start = 0
                local package_found = false
                if #lines == 0 then
                else
                  for _, line in ipairs(lines) do
                    if line:match("^package ") then
                      package_found = true
                      break
                    end
                  end
                end
                for ii, line in ipairs(lines) do
                  if package_found and (line:match("^import") or line:len() == 0) then
                    start = ii - 1
                    break
                  end
                end

                vim.api.nvim_buf_set_lines(0, start, start, false, {
                  "import neotype.*"
                })
                return nil
              end
            }
          }
        }),


      s("package", {
        t("package "), f(function(_)
        local filename = vim.fn.expand('%')
        local fn1, _ = filename:gsub("^.*src/main/scala/", "")
        local fn2, _ = fn1:gsub("^.*src/test/scala/", "")
        local fn3, _ = fn2:gsub("(.*)/.-%.scala$", "%1")
        local fn4, _ = fn3:gsub("/", ".")
        return fn4
      end)

      })
    }
    )

    ls.add_snippets('lua', {
      s("newproject",
        fmt([[
          local start_project = function()
            local Projects = require('user.projects')
            Projects.project_start('{}')
          end

          vim.schedule(start_project)
      ]], {
          i(1)
        }))
    })

    ls.setup({
      -- To enable auto expansion
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
  keys = {
    {
      '<C-L>',
      mode = { 'n' },
      function() require('luasnip').expand() end,
      silent = true
    },
    {
      '<C-J>',
      mode = { "i", "s" },
      function() require('luasnip').jump(1) end,
      silent = true
    },
    {
      '<C-K>',
      mode = { "i", "s" },
      function() require('luasnip').jump(-1) end,
      silent = true
    },
    {
      '<C-E>',
      mode = { "i", "s" },
      function()
        local ls = require('luasnip')
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end,
      silent = true
    }
  },
  event = "InsertEnter"
}

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
    local d = ls.dynamic_node
    local sn = ls.snippet_node
    local c = ls.choice_node
    local extras = require('luasnip.extras')
    local r = extras.rep
    local fmt = require('luasnip.extras.fmt').fmt
    local types = require('luasnip.util.types')
    local events = require('luasnip.util.events')
    local haskell_snippets = require('haskell-snippets').all

    ls.add_snippets('haskell', haskell_snippets, { key = 'haskell' })

    ls.add_snippets('purescript', {
      s("module", {
        t("module "), f(function(_)
        return vim.fn.expand("%:t:r")
      end), t(" where")
      }),

      s("dgen", {
        t("derive instance Generic "), i(1), t(" _")
      }),

      s("genshow",
        fmt(
          [[
          instance Show {} where
            show = genericShow
          ]], { i(1) }
        )
      )

    })

    local function get_package_name(_)
      local filename = vim.fn.expand('%:h')
      local fn1, _ = filename:gsub("^.*src/main/scala/", "")
      local fn2, _ = fn1:gsub("^.*src/test/scala/", "")
      local fn3, _ = fn2:gsub("^.*src/it/scala/", "")
      local fn4, _ = fn3:gsub("/", ".")
      return fn4
    end


    ls.add_snippets('scala', {
      s('opaquetype',
        d(1, function(_, _, _)
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local formatted = nil
          if #lines == 1 then
            formatted = fmt(
              [[
              package <>

              opaque type <> = <>
              object <> {
                def apply(value: <>): <> = value
                def unapply(value: <>): Some[<>] = Some(value)

                extension(value: <>) {
                  def underlying: <> = value
                }
              }

              ]],
              {
                f(get_package_name),
                d(1, function()
                  local filename = vim.fn.expand("%:t:r")
                  return sn(nil, { i(1, filename) })
                end),
                i(2),
                r(1),
                r(2),
                d(3, function(args, _, _, _)
                  return sn(nil,
                    c(1, {
                      i(nil, args[1]),
                      sn(nil, { t("Either[String, "), i(1, args[1]), t("]") }),
                      sn(nil, { t("Option["), i(1, args[1]), t("]") })
                    }, { 1 }))
                end, { 1 }),
                r(1),
                r(2),
                r(1),
                r(2),
              }, { delimiters = "<>" }
            )
          else
            formatted = fmt(
              [[
            opaque type <> = <>
            object <> {
              def apply(value: <>): <> = value
              def unapply(value: <>): Some[<>] = Some(value)

              extension(value: <>) {
                def underlying: <> = value
              }
            }

            ]],
              {
                i(1),
                i(2),
                r(1),
                r(2),
                d(3, function(args, _, _, _)
                  return sn(nil,
                    c(1, {
                      i(nil, args[1]),
                      sn(nil, { t("Either[String, "), i(1, args[1]), t("]") }),
                      sn(nil, { t("Option["), i(1, args[1]), t("]") })
                    }, { 1 }))
                end, { 1 }),
                r(1),
                r(2),
                r(1),
                r(2),
              }, { delimiters = "<>" }
            )
          end
          return sn(nil, formatted)
        end))
    })

    ls.add_snippets('scala', {
      s("newtype",
        d(1, function(_, _, _)
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          if #lines == 1 then
            return sn(nil,
              fmt(
                [[
                {}{}

                import neotype.*

                type {} = {}.Type
                object {} extends {}[{}]
                ]],
                {
                  t("package "),
                  f(get_package_name),
                  d(1, function()
                    local filename = vim.fn.expand("%:t:r")
                    return sn(nil, {
                      i(1, filename)
                    })
                  end),
                  r(1),
                  r(1),
                  c(2, { t("Newtype"), t("Subtype") }),
                  i(3)
                })
            )
          else
            return sn(nil, fmt(
                [[
              type {} = {}.Type
              object {} extends {}[{}]
              ]],
                {
                  i(1), r(1), r(1), c(2, { t("Newtype"), t("Subtype") }), i(3)
                }
              ),
              {
                node_callbacks = {
                  [events.leave] = function(node, event_args)
                    ---@diagnostic disable-next-line: redefined-local
                    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                    local start = 0
                    local package_found = false
                    local found_import_neotype = false
                    for ii, line in ipairs(lines) do
                      if line:match("^package ") then
                        package_found = true
                        start = ii
                      end

                      if line:match("^import neotype%.%*") then
                        found_import_neotype = true
                      end
                    end

                    if not found_import_neotype then
                      for ii, line in ipairs(lines) do
                        if package_found and (line:match("^import") or line:len() == 0) then
                          start = ii - 1
                          break
                        end
                      end

                      vim.api.nvim_buf_set_lines(0, start, start, false, {
                        "",
                        "import neotype.*"
                      })
                    end
                    return nil
                  end
                }
              })
          end
        end)),
      s({
        trig = "package",
        name = "Package",
        desc = "Insert package name",
        show_condition = function()
          local pos = vim.fn.getpos('.')
          return pos[2] == 1
        end
      }, {
        t("package "),
        f(get_package_name),
        t({ "", "", "" })
      })

    })

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
    -- {
    --   '<C-L>',
    --   mode = { 'n' },
    --   function() require('luasnip').expand() end,
    --   silent = true
    -- },
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

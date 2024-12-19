local command_overrides = {
  ['Gitsigns'] = true,
  ['Neorg'] = true,
  ['DBUI'] = true,
  ['Lazy'] = true,
  ['Telescope'] = true,
  ['DBUIToggle'] = true,
  ['WhichKey'] = true,
  ['Autosession'] = function()
    vim.ui.select({ 'search', 'delete' }, { prompt = 'Autosession' }, function(choice)
      if not choice or choice == '' then
        return
      end
      vim.cmd('Autosession ' .. choice)
    end)
  end
}

local command_action = function(prompt_bufnr)
  local selection = require('telescope.actions.state').get_selected_entry()
  if selection == nil then
    require('telescope.actions.utils').__warn_no_selection "builtin.commands"
    return
  end

  require('telescope.actions').close(prompt_bufnr)
  local val = selection.value
  local cmd = string.format([[:%s ]], val.name)


  local override = command_overrides[val.name]
  if type(override) == "function" then
    override()
    return
  elseif override or val.nargs == "0" then
    local cr = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
    cmd = cmd .. cr
  end

  vim.cmd [[stopinsert]]
  vim.api.nvim_feedkeys(cmd, "nt", false)
end

return {
  "nvim-telescope/telescope.nvim",
  dependencies = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        mappings = {
          i = { ['<C-h>'] = require('telescope.actions.layout').toggle_preview },
          n = { ['<C-h>'] = require('telescope.actions.layout').toggle_preview }
        },
        cache_picker = {
          num_pickers = 2
        }

      },
      pickers = {
        commands = {
          mappings = {
            i = { ['<CR>'] = command_action },
            n = { ['<CR>'] = command_action }
          }
        },
        builtin = {
          theme = "ivy"
        }
      },
      extensions = {
        ["fzy_native"] = {
          override_generic_sorter = false,
          override_file_sorter = true,
        },
        ["ui-select"] = {
          -- { layout_config = { prompt_position = 'bottom' } }
          require("telescope.themes").get_ivy({}),
        },
        ["ht"] = {
          hoogle_signature = {
            theme = "ivy",
          }
        },
      }
    })
    telescope.load_extension("fzy_native")
    telescope.load_extension("ui-select")
    telescope.load_extension('dap')
    telescope.load_extension('gh')
  end,
  event = "VeryLazy"
}

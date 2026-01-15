return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "kyazdani42/nvim-web-devicons" },
  event = "VeryLazy",
  opts = {
    extensions = { "quickfix", "lazy", "mason", "oil", "fzf", "toggleterm" },
    options = {
      disabled_filetypes = {
        "netrw",
        "dapui_stacks",
        "dapui_breakpoints",
        "dapui_watches",
        "dapui_scopes",
        "NeogitPopup",
        "NeogitStatus",
        "NeogitLogView",
        "NeogitGitCommandHistory",
        "NeogitCommitSelectView",
        "NeogitConsole",
        "NeogitCommitMessage",
        "NeogitBranchSelectView",
        "NeogitCommitView",
        "qf",
        "git",
        "neo-tree",
        "packer",
        -- "vim",
        -- "dbui"
        winbar = {
          "kulala_ui",
          "dbui",
          "dap-view",
          "dap-repl"
        }
      },
      ignore_focus = { "neo-tree" },
      theme = "catppuccin",
      icons_enabled = true,
      globalstatus = true,
    },
    sections = {
      lualine_a = {
        { "g:project_name" },
        {
          "branch",
          cond = function()
            return vim.o.filetype ~= "help"
          end
        }
      },
      lualine_b = { "diff" },
      lualine_c = {
        { "diagnostics" },
        {
          function()
            if vim.fn.reg_recording() ~= "" then
              return "Recording @" .. vim.fn.reg_recording()
            end
            if vim.fn.reg_executing() ~= "" then
              return "Executing @" .. vim.fn.reg_executing()
            end
            return ""
          end,
          color = 'Bold'
        },
        {
          function()
            local multiline = vim.v.statusmsg:find("\n")
            local length = string.len(vim.v.statusmsg)
            if length > 0 then
              vim.notify(vim.v.statusmsg, vim.diagnostics.severity.INFO)
              vim.v.statusmsg = ''
              return
            end
            if not multiline and length < 10 then
              return require('lualine.utils.utils').stl_escape(vim.v.statusmsg)
            else
              vim.notify(vim.v.statusmsg, vim.diagnostics.severity.INFO)
              vim.v.statusmsg = ''
            end
          end,
          cond = function()
            -- Why is "<" the statusmsg sometimes?
            return vim.v.statusmsg ~= "<"
          end
        },
        {
          function()
            local multiline = vim.v.warningmsg:find("\n")
            local length = string.len(vim.v.warningmsg)
            if length > 0 then
              vim.notify(vim.v.warningmsg, vim.diagnostics.severity.WARN)
              vim.v.warningmsg = ''
              return
            end
            if not multiline then
              return require('lualine.utils.utils').stl_escape(vim.v.warningmsg)
            else
              vim.notify(vim.v.warningmsg, vim.diagnostics.severity.WARN)
              vim.v.warningmsg = ''
            end
          end,
          color = 'WarningMsg'
        },
        {
          function()
            local multiline = vim.v.errmsg:find("\n")
            local length = string.len(vim.v.errmsg)
            if length > 0 then
              vim.notify(vim.v.errmsg, vim.diagnostics.severity.ERROR)
              vim.v.errmsg = ''
              return
            end
            if not multiline then
              return require('lualine.utils.utils').stl_escape(vim.v.errmsg)
            else
              vim.notify(vim.v.errmsg, vim.diagnostics.severity.ERROR)
              vim.v.errmsg = ''
            end
          end,
          color = 'Error'
        }
      },
      lualine_x = {
        function()
          return vim.fn["db_ui#statusline"]({
            show = { 'db_name', 'schema', 'table' },
            separator =
            ' > ',
            prefix = ' '
          })
        end
      },
      lualine_y = {
        { "lsp_status" },
        -- {
        --   function()
        --     ---@var clients { name: string}[]
        --     local clients = vim.lsp.get_clients({ bufnr = 0 })
        --     if (#clients > 0) then
        --       return clients[1].name or ""
        --     end
        --     return ""
        --   end
        -- },
        {
          "g:metals_bsp_status",
          cond = function()
            local ft = vim.o.filetype
            return ft == 'scala' or ft == "sbt"
          end
        }
      },
      lualine_z = {
        "tabs"
      }
    },
    winbar = {
      lualine_a = {
        {
          'mode',
          cond = function()
            return vim.bo.buftype ~= "terminal"
          end
        },
        {
          "b:terminal_mode",
          cond = function()
            return vim.bo.buftype and vim.bo.buftype == "terminal"
          end,
          color = function()
            if (vim.b.terminal_mode == 'NORMAL') then
              return "lualine_a_normal"
            end
            if (vim.b.terminal_mode == 'O-PENDING') then
              return "lualine_a_normal"
            end
            if (vim.b.terminal_mode == 'INSERT') then
              return "lualine_a_insert"
            end
            if (vim.b.terminal_mode == 'VISUAL') then
              return "lualine_a_visual"
            end
            if (vim.b.terminal_mode == 'V-LINE') then
              return "lualine_a_v_line"
            end

            return { bg = "blue", fg = "black", gui = "bold" }
          end
        },
      },
      lualine_b = {
        {
          "filename",
          symbols = {
            modified = '●', -- Text to show when the buffer is modified
            -- readonly = '[-]', -- Text to show to identify the alternate file
            directory = '', -- Text to show when the buffer is a directory
            unnamed = '[No Name]',
            newfile = '[New]'
          },
          cond = function()
            return vim.o.filetype ~= 'oil'
          end
        },
        {
          function()
            ---@var vim.b { db: tbl }
            return vim.b.db['db_url']
          end,
          cond = function()
            return vim.o.filetype == 'dbout'
          end
        },
        {
          "bufname",
          fmt = function(str)
            return str:gsub("oil://", "")
          end,
          cond = function()
            return vim.o.filetype == 'oil'
          end
        },
        -- {
        --   'buffers',
        --   symbols = {
        --     modified = ' ●', -- Text to show when the buffer is modified
        --     alternate_file = '#', -- Text to show to identify the alternate file
        --     directory = '', -- Text to show when the buffer is a directory
        --   },
        --   mode = 4
        -- }
      },
      lualine_c = {},
      lualine_x = { "searchcount", "encoding", "fileformat", "filetype" },
      lualine_y = {
        {
          "progress",
          disabled_buftypes = { "terminal" },
          cond = function()
            local is_term = vim.bo.buftype and vim.bo.buftype == "terminal"
            -- if (is_term) then return false end
            -- return true
            return not is_term
          end
        }
      },
      lualine_z = {
        {
          "location",
          disabled_buftypes = { "terminal" },
          cond = function()
            local is_term = vim.bo.buftype and vim.bo.buftype == "terminal"
            return not is_term
            -- if (is_term) then return false end
            -- return true
          end
        },
        { function() return "Buf " .. vim.fn.bufnr() end },
        { function() return "Win " .. vim.fn.winnr() end }
      },
    },
    inactive_winbar = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {
        { function() return "Buf " .. vim.fn.bufnr() end },
        { function() return "Win " .. vim.fn.winnr() end }
      },
    },
  }
}

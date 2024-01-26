local execute = vim.api.nvim_command

local ok, catppuccin = pcall(require, 'catppuccin')

if not ok then
  print("Could not load colorscheme")
else
  -- configure it
  catppuccin.setup(
  {
    flavour = "macchiato",
    -- flavor = "mocha",
    dim_inactive = {
      enabled = false,
      shade = "dark",
      percentage = 0.15,
    },
    transparent_background = false,
    term_colors = true,
    compile = {
      enabled = false,
      path = vim.fn.stdpath "cache" .. "/catppuccin",
    },
    styles = {
      comments = { "italic" },
      conditionals = { "italic" },
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
    },
    integrations = {
      treesitter = true,
      treesitter_context = false,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
        },
      },
      coc_nvim = false,
      lsp_trouble = false,
      cmp = true,
      lsp_saga = false,
      gitgutter = false,
      gitsigns = true,
      leap = false,
      telescope = true,
      nvimtree = {
        enabled = false,
        show_root = false,
        transparent_panel = false,
      },
      neotree = {
        enabled = true,
        show_root = true,
        transparent_panel = false,
      },
      dap = {
        enabled = true,
        enable_ui = true,
      },
      which_key = true,
      indent_blankline = {
        enabled = true,
        colored_indent_levels = true,
      },
      dashboard = false,
      neogit = true,
      neotest = false,
      noice = false,
      vim_sneak = false,
      fern = false,
      barbar = false,
      barbecue = false,
      bufferline = false,
      markdown = false,
      mason = true,
      lightspeed = false,
      ts_rainbow = true,
      hop = false,
      harpoon = false,
      notify = true,
      semantic_tokens = false, -- enable this
      telekasten = false,
      symbols_outline = true,
      mini = false,
      aerial = false,
      vimwiki = false,
      beacon = false,
      overseer = false,
      fidget = true
    },
    color_overrides = {},
    highlight_overrides = {},
  }
  )

  execute([[colorscheme catppuccin]])
end

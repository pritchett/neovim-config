return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local treesitter = require('nvim-treesitter')
    treesitter.install({
      'scala',
      'haskell',
      'purescript',
      'lua',
      'json',
      'python',
      'vim',
      'vimdoc',
      'query',
      'javascript',
      'yaml',
      'typescript',
      'bash'
    })
    end,
}
  -- config = function()
  --   -- require("nvim-treesitter.configs").setup({})
  -- end,

      -- -- One of "all", "maintained" (parsers with maintainers), or a list of languages
      -- ensure_installed = "all",
      -- modules = {},
      -- ignore_install = {},
      -- auto_install = false,
      --
      -- -- Install languages synchronously (only applied to `ensure_installed`)
      -- sync_install = false,
      --
      -- -- List of parsers to ignore installing
      -- -- ignore_install = { "javascript" },
      --
      -- highlight = {
      --   -- `false` will disable the whole extension
      --   enable = true,
      --
      --   -- list of language that will be disabled
      --   -- disable = { "c", "rust" },
      --
      --   -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      --   -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      --   -- Using this option may slow down your editor, and you may see some duplicate highlights.
      --   -- Instead of true it can also be a list of languages
      --   -- additional_vim_regex_highlighting = true,
      --   additional_vim_regex_highlighting = false,
      -- },
      -- rainbow = {
      --   enable = true,
      -- },
      -- indent = {
      --   enable = true,
      -- },
      -- incremental_selection = {
      --   enable = true,
      --   keymaps = {
      --     node_incremental = "v",
      --     node_decremental = "V",
      --   }
      -- },
      -- textobjects = {
      --   select = {
      --     enable = true,
      --
      --     -- Automatically jump forward to textobj, similar to targets.vim
      --     lookahead = true,
      --
      --     keymaps = {
      --       -- You can use the capture groups defined in textobjects.scm
      --       ["af"] = "@function.outer",
      --       ["if"] = "@function.inner",
      --       ["ac"] = "@class.outer",
      --       -- You can optionally set descriptions to the mappings (used in the desc parameter of
      --       -- nvim_buf_set_keymap) which plugins like which-key display
      --       ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
      --       -- You can also use captures from other query groups like `locals.scm`
      --       ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
      --       ["aP"] = "@parameter.outer",
      --       ["iP"] = "@parameter.inner"
      --     },
      --     lsp_interop = {
      --       enable = true,
      --       floating_preview_opts = { border = "rounded" },
      --       peek_definition_code = {
      --         ["<leader>df"] = "@function.outer",
      --         ["<leader>dF"] = "@class.outer",
      --       },
      --       include_surrounding_whitespace = true,
      --     }
      --   }
      -- }
      --

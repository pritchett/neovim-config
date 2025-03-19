return {
  'kristijanhusak/vim-dadbod-ui',
  -- dev = true,
  dependencies = {
    {
      'tpope/vim-dadbod',
      "vim-scripts/dbext.vim",
      lazy = true
    },
    {
      'kristijanhusak/vim-dadbod-completion',
      ft = { 'sql', 'mysql', 'plsql' },
      lazy = true
    },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_use_nvim_notify = true
    vim.g.dadbod_manage_dbext = 1
  end,
}

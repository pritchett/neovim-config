return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    disable_filetype = { "vim" },
    fast_wrap = {},
    -- check_ts = true,
    -- ts_config = {
    --   lua = { 'string' }, -- it will not add a pair on that treesitter node
    --   javascript = { 'template_string' },
    --   java = false,   -- don't check treesitter on java
    -- }
  }
}

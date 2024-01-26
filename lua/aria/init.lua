require "aria.deploy"
-- require "aria.graphql"

vim.api.nvim_create_user_command("Stacks", function()
  vim.cmd.split()
  vim.cmd.term("w3m http://incmd001.devfarm.ariasystems.net/devfarm/")
end, {})


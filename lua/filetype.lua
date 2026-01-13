-- [nfnl] fnl/filetype.fnl
return vim.filetype.add({extension = {sbt = "scala"}, filename = {vifmrc = "vim", [".gitlab-ci.yml"] = "yaml.gitlab"}}, "pattern", {[".*/kitty/.+%.conf"] = "kitty"})

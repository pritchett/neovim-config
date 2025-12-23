return {
  cmd = { 'npx', 'purescript-language-server', '--stdio' },
  filetypes = { 'purescript' },
  root_markers = { 'spago.yaml' },
  settings = {
    purescript = {
      formatter = "purs-tidy",
      addSpagoSources = true
    }
  }
}

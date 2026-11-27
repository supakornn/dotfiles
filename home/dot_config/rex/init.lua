-- Keep split shortcuts consistent across Macs.
rex.bind("cmd+d", "pane.split.right")
rex.bind("cmd+shift+d", "pane.split.down")

-- Import on demand from the local Mac's command palette, not at server startup.
rex.action({
  name = "import_catppuccin_macchiato",
  title = "Import Catppuccin Macchiato Theme",
  category = "Appearance",
  run = function()
    rex.client.queue("client.theme.import", {
      path = os.getenv("HOME") .. "/.config/rex/themes/Catppuccin Macchiato",
    })
  end,
})

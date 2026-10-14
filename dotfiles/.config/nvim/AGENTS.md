# Neovim configuration

LazyVim-based code viewer and lightweight editor alongside terminal tools and AI agents.
The canonical config is this directory, deployed to `~/.config/nvim` by the root
`mise.toml`. The ignored `.dotfiles/` tree is legacy, not the deployment source.

## Editing

- Add configuration overrides in `lua/config/` and plugin specs in `lua/plugins/`.
- Language extras are imported explicitly in `lua/config/lazy.lua`.
- Preserve `lazy-lock.json`; change pinned plugin versions only intentionally.
- Keep formatting on save, debugger/test adapters, extra linters, inlay hints,
  and code lenses disabled. Builds and tests belong in the terminal.
- Use Snacks pickers and blink.cmp. Scala commands must work without Telescope.
- Keep Herdr pane navigation: custom keymaps reapply `after/plugin/herdr-navigation.lua`
  after LazyVim's defaults.
- Java uses JDTLS; Metals attaches only to Scala/sbt. Kotlin uses JetBrains kotlin-lsp.
- OmniSharp must start with the resolved project root as its process cwd.
- Keep installation helpers local to Neovim; preserve the Kotlin public-host redirect
  workaround and the pinned/checksummed Scala installer.

## Verification

From the repository root, load this config against the existing Neovim plugin data:

```sh
XDG_CONFIG_HOME="$PWD/dotfiles/.config" nvim --headless \
  '+lua assert(vim.g.autoformat == false); print("Neovim config loaded")' +qa
"${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin/stylua" --check \
  dotfiles/.config/nvim/lua dotfiles/.config/nvim/init.lua \
  dotfiles/.config/nvim/scripts/install-kotlin.lua
bash -n dotfiles/.config/nvim/scripts/install-scala.sh
```

For language changes, also test live server attachment and navigation in a trusted
project. Scala type diagnostics should be checked after saving. See `README.md` for
installation prerequisites, shortcuts, verification history, and maintenance.

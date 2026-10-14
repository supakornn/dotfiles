# dotfiles

Personal macOS setup managed by [Homebrew](https://brew.sh/) and [Mise](https://mise.jdx.dev/).

```sh
git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles
./bootstrap.sh
```

- `Brewfile`: apps and system tools
- `mise.toml`: dotfile deployment and bootstrap tasks
- `dotfiles/`: files deployed into `$HOME`, including Mise tool versions
- `mise run install-herdr-plugins`: installs Annotate and Auto Title for Herdr
- `~/.gitconfig.local`: local Git identity

## Neovim

The [Neovim configuration](dotfiles/.config/nvim/README.md) uses LazyVim for lightweight
code navigation and editing, with multi-language LSP support including Kotlin, Scala,
and C#/.NET. Formatting on save and debugger/test-runner integrations are disabled.
See its README for language prerequisites, Scala installation, and the Kotlin installer
workaround. Plugin versions are pinned in `dotfiles/.config/nvim/lazy-lock.json`.

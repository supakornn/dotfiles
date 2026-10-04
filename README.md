# dotfiles

Personal macOS dotfiles managed by [Chezmoi](https://www.chezmoi.io/), [Homebrew](https://brew.sh/), and [Mise](https://mise.jdx.dev/).

No secrets, tokens, or company configuration are tracked.

## Install or migrate

```sh
git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles

./bootstrap.sh
```

`bootstrap.sh` installs Homebrew packages, writes the local Chezmoi source path, applies it, and installs Mise tools. On a machine previously managed by Stow, it replaces matching Stow symlinks with regular Chezmoi-managed files.

After setup, update with:

```sh
chezmoi update
```

## Tools

`Brewfile` installs macOS apps and system tools. `~/.config/mise/config.toml` tracks the latest version of developer tools.

Pi and OpenCode profile fragments are merged into their local final settings files, preserving existing local MCPs, models, plugins, and packages. Update Pi packages deliberately with `pi update --extensions`; bootstrap never updates them automatically.

Set Git identity in `~/.gitconfig.local`.

## Extras

- Install tmux plugins: clone [TPM](https://github.com/tmux-plugins/tpm) to `~/.tmux/plugins/tpm`, then press `prefix` + `I`.
- Install optional Herdr plugins manually: `herdr plugin install kryptamine/herdr-auto-title --yes` and `herdr plugin install plannotator/herdr-annotate --yes`.

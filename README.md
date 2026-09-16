# dotfiles

macOS dotfiles managed by [Chezmoi](https://www.chezmoi.io/) and [Homebrew](https://brew.sh/).

- `work`: shared shell, editor, terminal, and Git configuration.
- `personal`: work configuration plus AI tools and personal applications.
- No secrets, tokens, or company configuration are tracked.

## Install or migrate

```sh
git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles

# Company Mac: safe default
./bootstrap.sh work

# Personal Mac
./bootstrap.sh personal
```

`bootstrap.sh` installs the selected Brewfiles, writes the local Chezmoi profile, and applies it. On a machine previously managed by Stow, it replaces matching Stow symlinks with regular Chezmoi-managed files.

After setup, update with:

```sh
chezmoi update
```

## Profiles

`work` installs only `Brewfile.common` and ignores agent skills, Pi, OpenCode, and personal files. `personal` also installs `Brewfile.ai` and `Brewfile.personal`.

Pi and OpenCode profile fragments are merged into their local final settings files, preserving existing local MCPs, models, plugins, and packages. Update Pi packages deliberately with `pi update --extensions`; bootstrap never updates them automatically.

Set Git identity in `~/.gitconfig.local`.

## Extras

- Install tmux plugins: clone [TPM](https://github.com/tmux-plugins/tpm) to `~/.tmux/plugins/tpm`, then press `prefix` + `I`.
- Install optional Herdr plugins manually: `herdr plugin install kryptamine/herdr-auto-title --yes` and `herdr plugin install plannotator/herdr-annotate --yes`.

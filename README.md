# dotfiles

Public macOS dotfiles managed with [Homebrew](https://brew.sh/) and [GNU Stow](https://www.gnu.org/software/stow/).

- `common/`: shared, work-safe configuration.
- `personal/`: personal-Mac-only configuration.
- No secrets, tokens, or company configuration are tracked.

## Install

```sh
git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles

# Work Mac
./install.sh common

# Personal Mac
./install.sh common personal

# Move conflicting files aside first
./install.sh --backup-existing common personal
```

## Included

Common installs shell, terminal, Git, Neovim, tmux, OpenCode, and Catppuccin configuration. Personal adds `uv`, personal Git defaults, and personal OpenCode settings.

OpenCode skills live in `~/.agents/skills/`. Personal MCPs, the default model, and OpenCode Quota are installed only with the `personal` profile. Company MCPs and credentials stay local.

Set Git identity in `~/.gitconfig.local`. Authenticate OpenCode with `/connect`.

## Extras

- Switch themes: `theme light`, `theme dark`, or `theme auto`.
- Install tmux plugins: clone [TPM](https://github.com/tmux-plugins/tpm) to `~/.tmux/plugins/tpm`, then press `prefix` + `I`.

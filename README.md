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

Common installs shell, terminal, Git, Neovim, tmux, Pi, and Catppuccin configuration. Personal adds `uv`, personal Git defaults, Pi settings, and OpenCode settings.

Pi skills live in `~/.pi/agent/skills/`. Personal Pi settings add the default model and Codex usage plugin. Personal OpenCode settings configure its model, MCPs, and quota plugin in `~/.config/opencode/`; no OpenCode skills are managed, so it does not use `~/.agents/`.

Set Git identity in `~/.gitconfig.local`.

## Extras

- Switch themes: `theme light`, `theme dark`, or `theme auto`.
- Install tmux plugins: clone [TPM](https://github.com/tmux-plugins/tpm) to `~/.tmux/plugins/tpm`, then press `prefix` + `I`.

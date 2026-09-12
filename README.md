# dotfiles

Public macOS dotfiles managed with [Homebrew](https://brew.sh/) and [GNU Stow](https://www.gnu.org/software/stow/).

- `common/` contains safe configuration and tools shared by both Macs.
- `personal/` contains personal-Mac-only tools and Git configuration.
- No secrets, keys, tokens, work Git configuration, or company information belong here.

The previous chezmoi setup is preserved on the [`legacy-chezmoi`](../../tree/legacy-chezmoi) branch.

## Install

Clone the repository, then choose a profile:

```sh
git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles

# Office Mac: shared, work-safe profile
./install.sh common

# Personal Mac: shared profile plus personal tools/config
./install.sh common personal

# Migrating from the old chezmoi setup on this Mac: back up conflicting files,
# then create Stow links.
./install.sh --backup-existing common personal
```

The script installs Homebrew when necessary, installs the selected Brewfiles, and Stow-links the selected files into `$HOME`. It fails rather than overwriting conflicting files. During a migration, pass `--backup-existing` to move conflicting files into a timestamped directory below `~/.dotfiles-backup/` before linking.

## What is managed

### Common

Fish, Starship, Ghostty, tmux, Git, Lazygit, bat, btop, Herdr, Neovim, OpenCode, and Catppuccin Macchiato configuration. Supporting Fish tools (`eza`, `fzf`, `fd`, and `zoxide`) are installed too.

Herdr is installed but deliberately not registered as a login/background service. Start it manually with `herdr`. Herdr, Plannotator TUI, btop, and Neovim plugin-lock defaults are copied into local runtime files, so UI changes and plugin updates never modify this repository.

Neovim is installed, but NvChad is not tracked yet. Install NvChad separately; add only your own future customizations under `common/.config/nvim/`.

### Personal

`uv`, a generic personal Git configuration, a global Git ignore file, and the personal OpenCode model default. OpenCode authentication, sessions, logs, package caches, and runtime state are intentionally excluded. Git identity, signing keys, tokens, and credential helpers are also intentionally not managed.

Set your GitHub identity locally after installing the personal profile. Use the verified noreply email shown in GitHub’s email settings:

```sh
cat > ~/.gitconfig.local <<'EOF'
[user]
  name = Your Name
  email = YOUR_GITHUB_NOREPLY_EMAIL
EOF
chmod 600 ~/.gitconfig.local
```

`~/.gitconfig.local` is included by the tracked Git config but is never synced.

## OpenCode

- Shared skills are Stow-linked to `~/.agents/skills/`.
- `opencode/common/settings.json` supplies shared MCP servers.
- `opencode/personal/settings.json` supplies the personal model default.
- The installer replaces local `~/.config/opencode/opencode.jsonc` with the selected profiles.
- Authentication, OAuth credentials, sessions, logs, and package caches are never tracked.

Run `opencode`, then use `/connect` to authenticate. Third-party MCP servers and skills run with your user permissions; review updates before promoting them to the shared profile.

## Tmux plugins

The tmux configuration retains TPM plugin declarations. Install TPM manually if you want those plugins:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then open tmux and press `prefix` + `I`.

## Themes

Use `theme light`, `theme dark`, or `theme auto` after installing. Light uses Catppuccin Latte; dark uses Catppuccin Macchiato. `auto` selects the current macOS appearance. Ghostty follows future macOS appearance changes itself; rerun `theme auto` after a later appearance change to update the other terminal tools.

## Daily workflow

Edit the file inside `common/` or `personal/`; its matching file in your home directory is a symlink. Re-run the selected install command after adding new files.

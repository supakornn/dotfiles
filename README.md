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
```

The script installs Homebrew when necessary, installs the selected Brewfiles, and Stow-links the selected files into `$HOME`. It fails rather than overwriting conflicting files; move or back up a conflicting file, then rerun it.

## What is managed

### Common

Fish, Starship, Ghostty, tmux, Git, Lazygit, bat, btop, Herdr, Neovim, and Catppuccin Macchiato configuration. Supporting Fish tools (`eza`, `fzf`, `fd`, and `zoxide`) are installed too.

Herdr is installed but deliberately not registered as a login/background service. Start it manually with `herdr`.

Neovim is installed, but NvChad is not tracked yet. Install NvChad separately; add only your own future customizations under `common/.config/nvim/`.

### Personal

`uv`, a generic personal Git configuration, and a global Git ignore file. Git identity, signing keys, tokens, and credential helpers are intentionally not managed.

## Tmux plugins

The tmux configuration retains TPM plugin declarations. Install TPM manually if you want those plugins:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then open tmux and press `prefix` + `I`.

## Daily workflow

Edit the file inside `common/` or `personal/`; its matching file in your home directory is a symlink. Re-run the selected install command after adding new files.

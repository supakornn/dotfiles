# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io). macOS only.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/supakornn/dotfiles/main/install.sh | bash
```


## What's Included

- [Fish](https://fishshell.com) — shell
- [Starship](https://starship.rs) — prompt
- [Ghostty](https://ghostty.org) — terminal
- [Neovim](https://neovim.io) — editor (LazyVim)
- [Zed](https://zed.dev) — editor
- [Tmux](https://github.com/tmux/tmux) — terminal multiplexer
- [Lazygit](https://github.com/jesseduffield/lazygit) — git TUI
- [mise](https://mise.jdx.dev) — runtime version manager
- [uv](https://docs.astral.sh/uv) — Python toolchain
- [btop](https://github.com/aristocratos/btop) — system monitor
- [Spicetify](https://spicetify.app) — Spotify customization
- [Karabiner-Elements](https://karabiner-elements.pqrs.org) — keyboard remapping

## Runtime Management

All language runtimes managed by [mise](https://mise.jdx.dev) — no fnm, pyenv, or chruby needed:

```bash
mise install        # install everything in ~/.config/mise/config.toml
mise install node   # install single tool
mise use node@22    # switch version globally
```

Python is managed entirely by [uv](https://docs.astral.sh/uv):

```bash
uv python install 3.13
uv run script.py
```

## Neovim

Built on [LazyVim](https://www.lazyvim.org) with [Catppuccin](https://github.com/catppuccin/nvim).
Neovim auto-switches flavor based on macOS system appearance (Macchiato = dark, Latte = light).
All other apps follow `catppuccin_flavor` in `~/.config/chezmoi/chezmoi.toml` — changed via the `theme` command.

Neovim config inspired by [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public).

## Theme Switching

Switch Catppuccin flavor across all apps (Ghostty, Zed, Fish, Tmux, bat, btop, lazygit, Starship):

```bash
theme              # toggle dark/light
theme dark         # Catppuccin Macchiato
theme macchiato    # Catppuccin Macchiato
theme mocha        # Catppuccin Mocha
theme frappe       # Catppuccin Frappe
theme light        # Catppuccin Latte
```

Requires `catppuccin_flavor` set in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    wakatimeApiKey = "your-key-here"
    catppuccin_flavor = "macchiato"
```

## Daily Workflow

```bash
# Edit a file normally, then sync to chezmoi:
chezmoi add ~/.config/fish/config.fish

# Edit directly in chezmoi source:
chezmoi edit ~/.config/ghostty/config
chezmoi apply

# Check what's changed:
chezmoi diff
chezmoi status
```

## Secrets

`~/.config/chezmoi/chezmoi.toml` is local only, not tracked:

```toml
[data]
    wakatimeApiKey = "your-key-here"
    catppuccin_flavor = "macchiato"
```

# dotfiles

My personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/supakornn/dotfiles/main/install.sh | bash
```

## What's included

| Tool | Description |
|------|-------------|
| [Fish](https://fishshell.com) | Shell |
| [Starship](https://starship.rs) | Prompt |
| [Ghostty](https://ghostty.org) | Terminal |
| [Zed](https://zed.dev) | Editor |
| [Tmux](https://github.com/tmux/tmux) | Terminal multiplexer |
| [Lazygit](https://github.com/jesseduffield/lazygit) | Git TUI |
| [btop](https://github.com/aristocratos/btop) | System monitor |
| [Spicetify](https://spicetify.app) | Spotify customization |
| [Karabiner-Elements](https://karabiner-elements.pqrs.org) | Keyboard remapping |
| [Claude Code](https://claude.ai/code) | AI coding assistant |

## Daily Workflow

**Edit a config and save to chezmoi:**
```bash
# Edit the file normally, then:
chezmoi add ~/.config/fish/config.fish
```

**Edit directly in chezmoi source:**
```bash
chezmoi edit ~/.config/ghostty/config
chezmoi apply ~/.config/ghostty/config
```

**Check what's changed:**
```bash
chezmoi diff
chezmoi status
```

**Commit and push:**
```bash
cd ~/.local/share/chezmoi
git add -A && git commit -m "update configs" && git push
```

## Theme Switching

Switch between Catppuccin dark and Latte (light) across all apps at once:

```bash
theme              # toggle dark/light
theme dark         # Catppuccin Macchiato
theme macchiato    # Catppuccin Macchiato
theme mocha        # Catppuccin Mocha
theme frappe       # Catppuccin Frappe
theme light        # Catppuccin Latte
```

Covers: Ghostty, Zed, Neovim, Tmux, Fish, Starship, bat, btop, lazygit, fzf.

## Secrets

The WakaTime API key in Zed settings is **not** stored in this repo.  
It lives in `~/.config/chezmoi/chezmoi.toml` (local only):

```toml
[data]
    wakatimeApiKey = "your-key-here"
    catppuccin_flavor = "macchiato"
```

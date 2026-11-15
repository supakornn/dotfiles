# dotfiles

My macOS setup: Fish, Ghostty, Herdr, tmux, Neovim, Zed, and Pi, with
Catppuccin Latte and Geist Mono. Feel free to fork it or copy the parts you like.

- **Homebrew** manages apps and standalone tools.
- **Mise** manages language runtimes.
- **chezmoi** manages configuration in [home/](home/).

## Setup

Review the [package lists](packages/) and configuration before installing.
Back up your existing configs: this setup is opinionated, not a minimal installer.
Herdr desktop requires Apple Silicon.

```sh
git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles
./dot init --profile personal  # Or: --profile work
```

`init` installs dependencies and applies configuration. Sign-ins, licences,
and macOS permissions need manual setup.

### Profiles

| Scope | Includes |
| --- | --- |
| [Base](packages/Brewfile.base) | Shared apps, tools, runtimes, editor/shell configs, Pi packages, and Cua |
| [Personal](packages/Brewfile.personal) | Extra apps, GitHub CLI/MCP, REA with Ghidra, and research MCP servers |
| [Work](packages/Brewfile.work) | Base only; Cua is the only managed MCP server, with no Pi provider/model defaults |

Personal installs **Base + Personal**; Work installs **Base + Work**, never Personal.
The profile is saved locally in `~/.config/chezmoi/chezmoi.json` (under
`$XDG_CONFIG_HOME` if set). Automatic profile switching is refused.

## Everyday commands

Run from the repository:

```sh
./dot diff             # Preview config changes
./dot apply            # Apply config only
./dot init             # Install missing dependencies and apply config
./dot init --upgrade   # Also allow Homebrew upgrades
./dot status           # Show pending config changes
./dot doctor           # Check the setup without installing
./dot package list     # Show packages by scope
```

Existing packages are not upgraded unless requested. Microsoft apps, Zoom,
and Chrome are installed manually.

## Good to know

- Review `./dot diff` before applying. `--force` skips confirmation and makes no backups.
- Git identity, credentials, sessions, and local-only data stay local. Pi settings
  and MCP servers are preserved except for entries managed by this profile;
  back up same-name customizations.
- Profiles are not a security boundary: existing Personal tools and MCP servers
  are not removed on Work.
- After theme changes, restart/reload apps and run `bat cache --build`.
  Zed's Catppuccin and Catppuccin Icons extensions must be available separately.
- To undo configuration changes, restore the previous sources or your backups,
  preview the diff, and apply explicitly. Installed software is not removed automatically.

### Herdr desktop

With Herdr desktop running, select the bundled layout and theme:

```sh
herdr-app check ~/.config/herdr-app/mods/spaces-icons
herdr-app check ~/.config/herdr-app/mods/tabs-graph
herdr-app do layout.switch '{"name":"catppuccin"}'
herdr-app do app.theme '{"name":"catppuccin-latte"}'
```

Layout and mods adapted from [MarcozVD/herdr-layout-catppuccin](https://github.com/MarcozVD/herdr-layout-catppuccin).
Colors from [Catppuccin](https://github.com/catppuccin/palette).
Contributor instructions: [AGENTS.md](AGENTS.md).

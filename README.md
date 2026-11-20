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
| [Base](packages/Brewfile.base) | Shared apps, tools, runtimes, editor/shell configs, Pi packages, shared agent skills, and Cua |
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

`init` and `apply` show a short task list and keep warnings, errors, and prompts
visible. Use `./dot diff` for the full preview, or add `--verbose` to `init`
or `apply` for detailed output.

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

### Agent skills

Both profiles install all of [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
and only `bro` from [backnotprop/pstack](https://github.com/backnotprop/pstack)
through the native `npx skills` installer during `dot init`:

```sh
npx --yes skills add addyosmani/agent-skills --global --agent pi --skill '*' --yes
npx --yes skills add backnotprop/pstack --global --agent pi --skill bro --yes
```

These skills and `~/.agents/.skill-lock.json` are installer-owned, not chezmoi sources.
Pi and other universal-skill agents share `~/.agents/skills`. Back up local edits
before refreshing. `dot doctor` checks the recorded Addy Osmani skills and `bro`
without downloading anything or comparing against the latest upstream list.

`dot init` does not remove previously installed skills. To migrate from the full
pstack collection, back up the skill directories and lock file, then list the
pstack entries other than `bro`:

```sh
jq -r '.skills | to_entries[] | select(.value.source == "backnotprop/pstack" and .key != "bro") | .key' ~/.agents/.skill-lock.json
```

Review the names, then remove only those with `npx skills remove --global --yes <names...>`.
Before installing over any old vendored Addy Osmani skills, back up their local edits
and ensure they are no longer managed by chezmoi. To roll back, remove only the
newly installed names and restore your backed-up files and lock.

### Herdr desktop

With Herdr desktop running, select the bundled layout and theme:

```sh
herdr-app check ~/.config/herdr-app/mods/spaces-icons
herdr-app check ~/.config/herdr-app/mods/tabs-graph
herdr-app do layout.switch '{"name":"catppuccin"}'
herdr-app do app.theme '{"name":"catppuccin-latte"}'
```

**Auto Title** is included on both profiles. Press `Cmd+Option+T` to open its
installer/status popup. The optional **Install** button downloads a checksum-checked
GitHub release and starts a login service; `dot init` and `dot apply` only deploy
the popup, not the service. Existing shortcuts are preserved; a conflicting
`Cmd+Option+T` binding must be resolved before applying. Check the mod with
`herdr-app check ~/.config/herdr-app/mods/auto-title`.

The popup is vendored from [kryptamine/herdr-auto-title](https://github.com/kryptamine/herdr-auto-title/tree/67c03f3a1ed0ce6717f815b3609e3e32b496c39b/mod)
(v0.22.3). The service manages its own updates and local state. To remove the
service, run `"$HOME/Library/Application Support/herdr-auto-title/bin/herdr-auto-title" desktop uninstall`;
removing the popup files alone does not stop it.

Layout and mods adapted from [MarcozVD/herdr-layout-catppuccin](https://github.com/MarcozVD/herdr-layout-catppuccin).
Colors from [Catppuccin](https://github.com/catppuccin/palette).
Contributor instructions: [AGENTS.md](AGENTS.md).

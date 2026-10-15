# dotfiles

macOS configuration managed with chezmoi, Homebrew, and Mise.

## Setup

```sh
git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles
./dot init --profile personal  # Use work on the work Mac
```

Personal installs **Base + Personal**. Work installs **Base + Work**, never
Personal. Package lists live in [packages/](packages/); configuration in [home/](home/).
The selected profile is saved locally; automatic profile switching is refused.

Back up existing configs and review the diff before applying. `--force` skips
confirmation and makes no backups. Sign-ins, licences, and macOS permissions
may need manual setup.

Existing Pi MCP servers and settings are preserved. Dotfiles replaces only its
own server entries (Cua on Work); back up any same-name local customizations.

## Commands

```sh
dot diff             # Preview config changes
dot apply            # Apply config only
dot init             # Install missing dependencies and apply config
dot init --upgrade   # Also allow Homebrew upgrades
dot status           # Show pending config changes
dot doctor           # Check the setup
dot package list     # Show packages by profile
```

Homebrew owns apps and standalone tools; Mise owns language runtimes.
Existing packages are kept without upgrades unless requested.
Microsoft apps, Zoom, and Chrome are installed manually.

Contributor instructions: [AGENTS.md](AGENTS.md).

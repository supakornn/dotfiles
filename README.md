# dotfiles

My macOS configuration, packages, and language toolchains.

- [Brewfile](Brewfile): apps, fonts, shells, and standalone tools.
- [Mise config](dotfiles/.config/mise/config.toml): Bun, Go, Java, Node, Python, and Rust.
- [Deployment config](mise.toml): dotfile mappings and setup tasks.

Project dependencies, including TypeScript, belong in each project. Homebrew may
install its own runtime dependencies; Mise selects the versions I use in my shell.

## Setup

On macOS 14+, `--apply` installs [Homebrew](https://brew.sh/), Mise, and a Mise-managed
Python if needed, then checks conflicts before installing packages and deploying
dotfiles. It also installs Cua Driver and Pi packages, prepares REA, and installs
Herdr plugins. Run from an interactive terminal for installation prompts.

```sh
git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles

# Review the repository before applying it.
./bootstrap.sh          # Preview; reports missing prerequisites without installing.
./bootstrap.sh --apply  # Prepare prerequisites, install packages, and deploy.
```

Cloning requires Git; macOS may prompt you to install its Command Line Tools.
Preview needs Homebrew and Mise already available; otherwise it reports what is
missing and stops.

## Bootstrap options

| Option | Effect |
| --- | --- |
| No options | Preview only; no installation or deployment. |
| `--apply` | Prepare Homebrew, Mise, and Python; install packages, deploy dotfiles, and run setup tasks. |
| `--force` | With `--apply`, back up and replace conflicting managed files. |
| `--upgrade` | With `--apply`, allow Homebrew package upgrades. |
| `--skip-packages` | With `--apply`, skip Homebrew and agent package installation; requires Homebrew and Mise already installed. |

Backups are stored in `~/.dotfiles-backups/deployment-*`. Keep them private.
Pi credentials/sessions, local-only skills, and Fish universal variables stay local.
Managed configuration files can still be replaced by `--force`.

See [setup notes](docs/setup.md) for permissions, recovery, and MCP prerequisites.

## Updates

Use `brew upgrade` for apps and tools, and `mise upgrade` for language toolchains.
Java tracks Temurin 21 LTS; the other global toolchains track `latest`. Projects can
override these defaults in their own `mise.toml`.

## Tests

```sh
python3 -m unittest discover -s tests -v
bash -n bootstrap.sh
```

Tests cover bootstrap safeguards, mocked fresh-Mac installation, agent setup, and
deployment into a temporary home. They do not install Homebrew packages or verify
remote MCP authentication or a fresh Mac setup.

# dotfiles

My macOS configuration, packages, and language toolchains.

- [Brewfile](Brewfile): apps, fonts, shells, and standalone tools.
- [Mise config](dotfiles/.config/mise/config.toml): Bun, Go, Java, Node, Python, and Rust.
- [Deployment config](mise.toml): dotfile mappings and setup tasks.

Project dependencies, including TypeScript, belong in each project. Homebrew may
install its own runtime dependencies; Mise selects the versions I use in my shell.

## Setup

Requires [Homebrew](https://brew.sh/), Mise, and Python 3.8+ for deployment.

```sh
brew install mise

git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles

# Review the config before trusting it.
mise trust ./mise.toml
./bootstrap.sh          # Preview packages and dotfile changes.
./bootstrap.sh --apply  # Install missing packages and deploy.
```

If Python is not available, run the apply command through
`mise exec python@latest -- ./bootstrap.sh --apply`.

## Bootstrap options

| Option | Effect |
| --- | --- |
| No options | Preview only; no installation or deployment. |
| `--apply` | Install missing packages, deploy dotfiles, build Bat's cache, and install Herdr plugins. |
| `--force` | With `--apply`, back up and replace conflicting managed files. |
| `--upgrade` | With `--apply`, allow Homebrew package upgrades. |
| `--skip-packages` | With `--apply`, skip Homebrew installation; use existing packages. |

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

Tests cover bootstrap safeguards and deployment into a temporary home. They do not
install Homebrew packages or verify remote MCP authentication or a fresh Mac setup.

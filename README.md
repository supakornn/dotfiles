# dotfiles

Personal macOS setup managed by [Homebrew](https://brew.sh/) and [Mise](https://mise.jdx.dev/).

```sh
git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles
./bootstrap.sh                 # Preview only; does not install or deploy.
./bootstrap.sh --apply         # Install missing packages and deploy non-conflicting files.
```

## Safe bootstrap

Prerequisites: Homebrew, Mise, and Python 3.8+ on PATH. Install Homebrew using its
[official instructions](https://brew.sh/), then `brew install mise`. If Python is
not yet available, run bootstrap through
`mise exec python@latest -- ./bootstrap.sh --apply`.

Review the repository before trusting it (`mise trust ./mise.toml`). A preview
checks packages and shows Mise's planned deployment; it does not install plugins,
change dotfiles, or grant trust. Only `--apply` changes the machine.

```sh
# After reviewing conflicts, back them up and replace managed destinations.
./bootstrap.sh --apply --force

# Explicitly allow updates of installed Homebrew packages too.
./bootstrap.sh --apply --force --upgrade

# Test deployment with the packages already installed; do not invoke brew bundle.
./bootstrap.sh --apply --force --skip-packages
```

Package installation uses `--no-upgrade` unless `--upgrade` is supplied. Homebrew
may still upgrade a dependency when required by a new installation. Run from an
interactive terminal for administrator-password prompts (such as Vorssaint) and
App Store sign-in/installation (Tailscale). On newer Homebrew versions, review and
approve individual tap packages if requested, for example
`brew trust --formula anomalyco/tap/opencode-v2`. Bootstrap never trusts whole taps.

Before replacing conflicts, bootstrap backs them up under
`~/.dotfiles-backups/deployment-*` with a manifest. Backup directories are private
(mode 700), may contain sensitive local data, and must not be committed or shared.
All backups must succeed before deployment begins. A failed apply leaves backups
available for manual restoration; they are not a package rollback mechanism.
Interrupted Mise operations block deployment: inspect `mise dot history --pending`
and review saved state before recovery. Do not restore an old operation blindly.
Legacy parent-directory symlinks also require manual migration before narrower
mappings can be applied safely.

### Configuration versus local state

- Pi manages only the declared settings, MCP, keybindings, and theme files, in copy
  mode. Authentication, sessions, caches, device state elsewhere, and local-only
  extensions are not replaced. Managed settings themselves are replaced on apply;
  review their differences before using `--force`.
- Agent skill and Fish subdirectories use `symlink-each`: unrelated local skills,
  startup files, and `fish_variables` remain in place. Mise's global config maps
  only `config.toml`, not the entire configuration directory.
- btop config is copied so its save-on-exit behavior cannot rewrite the tracked
  source. To retain new preferences, edit the selected settings in the repo;
  redeploying intentionally resets the managed file to those settings.

### MCP prerequisites

The captured server set includes DeepWiki and REA, not Context7. GitHub's header
runs `gh auth token` locally; authenticate with `gh auth login`. No token is stored
in this repo. Cua Driver must exist at `~/.local/bin/cua-driver` (Pi expands `~/`).
REA uses Node/npx and pins `rea-agents@6.4.0`. Its Hopper launcher uses `${HOME}`
instead of a username; install Hopper at `~/Applications/Hopper Disassembler.app`
or adjust that optional native-disassembly integration. No Hopper installation is
included here. See Pi's installed `docs/mcp.md` for variable/command expansion.

### Validation

```sh
python3 -m unittest discover -s tests -v
bash -n bootstrap.sh
```

Tests include actual Mise deployment in a temporary home, state preservation,
private backups, idempotence, and mocked package-manager calls. They do not install
Homebrew packages, test remote MCP authentication, or prove a fresh Mac setup.

## Package ownership

- **Homebrew (`Brewfile`):** standalone CLIs, build tools, shells, GUI apps, and fonts.
- **Mise (`dotfiles/.config/mise/config.toml`):** global language runtimes/toolchains
  (Bun, Go, Java, Node, Python, and Rust), with optional project-specific versions.
- **Project package managers:** project dependencies, including TypeScript, linters,
  and formatters. Install TypeScript per project (for example,
  `npm install --save-dev typescript`); no global compiler is managed here.

Do not explicitly install the same runtime or CLI through both managers. Homebrew
may still install runtimes as dependencies (for example, Node for Pi and OpenJDK
for Maven); keep those dependencies. Mise selects the personal
runtime versions in the activated Fish shell. Cargo and npm come with their
respective toolchains; `cargo-binstall` is a separate Homebrew CLI.

```sh
# Set a personal default (installs it if necessary).
mise use --global node@24

# Select a different version for one project, without changing the default.
cd /path/to/project
mise use node@22

# Run with the selected project runtimes, including in non-interactive scripts.
mise exec -- node --version
```

Use `brew upgrade` for Homebrew tools and `mise upgrade` for configured language
runtimes. Java tracks Temurin 21 LTS; other global runtimes track `latest`. Pin
project versions when compatibility or reproducibility matters. Avoid separate fnm/uv/rustup version
selection that competes with Mise for the same runtime. uv may still manage Python
dependencies and virtual environments using the Mise-selected Python. Use
`uv tool install` for Python CLI apps not managed by Homebrew; pipx is not needed.
For example, `uv venv --python "$(mise which python)"` explicitly creates an
environment with Mise's selected interpreter.

Mise also remains responsible for dotfile deployment and the bootstrap tasks in the
root `mise.toml`; those tasks do not imply ownership of the CLI installations.

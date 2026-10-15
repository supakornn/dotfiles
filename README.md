# dotfiles

macOS 14+ setup. **chezmoi** manages files, **Homebrew** installs apps/tools,
**Mise** selects language runtimes. One Bash `dot` command ties them together.

## Setup

```sh
git clone https://github.com/supakornn/dotfiles.git ~/Documents/dotfiles
cd ~/Documents/dotfiles
./dot init --profile personal   # Or work
```

Git may prompt for Apple's Command Line Tools. `init` prepares Homebrew, chezmoi,
Mise, and jq, installs Base plus the selected bundle, applies config, and prepares
runtimes, Cua, Pi packages, and Herdr plugins. Existing Pi packages/Cua are kept.
Sign-ins, licences, and macOS permissions remain interactive.

**On an existing Mac, back up local configs and review the source first.** Setup
shows `chezmoi diff` before continuing. Apply uses native chezmoi behavior, not a
custom conflict/backup manager. `--force` skips confirmation; it makes no automatic
backup. No software is automatically uninstalled or unrelated local files deleted.

Existing Homebrew packages are reused without upgrades by default. Current
Homebrew Bundle can adopt identical manually installed apps; different copies may
stop installation rather than be replaced. Use `HOMEBREW_BUNDLE_CASK_SKIP` for apps
you intentionally keep outside Homebrew. Legacy managed-directory symlinks are
refused: move the link aside, retain its target and any local-only files, then retry.

## Daily use

```sh
dot diff                     # Preview configuration changes
dot status                   # List changes
dot apply                    # Configuration only; no installs/upgrades
dot init                     # Install missing software for the saved profile
dot init --upgrade           # Also allow Homebrew upgrades
dot doctor                   # Native verification/tool checks; work leftovers

dot package list             # All bundles, labelled
dot package list base        # Or personal / work: declarations in that bundle
```

The profile is saved in `~/.config/chezmoi/chezmoi.json` (or your XDG config dir).
Profile switching is deliberately refused: review local files/software before
changing that selection manually. Ignored personal files can still exist or load
on a previously personal machine. Profiles are not security isolation.

## What's shared

- [Base packages](packages/Brewfile.base) plus [Personal](packages/Brewfile.personal)
  or [Work](packages/Brewfile.work) additions. Work currently has no extra packages.
- Nine runtimes at `latest`: Java, Kotlin, Scala, .NET, Node, Bun, Python, Rust, Go.
  Projects can pin versions. Maven/Gradle/Coursier remain Homebrew tools.
- Shell/editor/terminal configs, font, Herdr plugins, Pi packages/theme/keybindings,
  general skills, and Cua. Cua owns its version-matched SDK skill and agent links.
- REA, research/GitHub MCPs, and Cord are personal-only. Work has only Cua MCP and
  no supplied Pi provider/model. Existing local model choices remain untouched.
- btop changes only its theme. Existing Git identity and credential settings are
  preserved; `~/.gitconfig.local` provides optional overrides. Credentials,
  sessions, local skills, and `~/.feynman` remain unmanaged.

Microsoft apps, Zoom, and Chrome are manual installs, excluded from both profiles.
An existing Hopper executable in `/Applications/Hopper Disassembler.app` is kept.
The old Mise file deployment is retired; [home/](home/) is the chezmoi source.
`bootstrap.sh` is only a compatibility shim: default previews; `--apply` runs init.

## Check

```sh
bash tests/smoke.sh           # Requires chezmoi/jq; isolated homes, fake installers
bash -n dot bootstrap.sh tests/smoke.sh
```

The single test checks both profiles, first adoption with existing tools/configs,
full init with fake installers, repeat runs, exclusions, state preservation,
installer failures, directory-symlink safety, doctor, and profile-switch refusal.
It does not prove real fresh-Mac downloads, app permissions, or authentication.

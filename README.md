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
Neovim's `lazy-lock.json` stays local to each Mac, managed by Lazy.

Plannotator reviews use the browser through the shared Pi extension. Herdr
Annotate is no longer installed by dotfiles; on an existing Mac, remove it with
`herdr plugin uninstall annotate`. Saved annotations and review history remain
local and are not deleted. `prefix+o` returns to Herdr's default notification
target shortcut after applying the configuration.

## REA with Ghidra (Personal only)

REA uses free, open-source Ghidra instead of requiring a Hopper licence.
Homebrew installs the `ghidra` formula; Mise continues to own the shared Java
runtime (`latest`). Homebrew's transitive `openjdk@21` dependency can remain
installed, but REA runs through Mise using the home configuration, not a project's
runtime selection. MCP startup disables Mise auto-installation; run `dot init`
explicitly to install missing runtimes.

Chezmoi manages the Personal REA MCP entry with `REA_ANALYSIS_PROVIDER=ghidra`
and the stable `$(brew --prefix)/opt/ghidra/libexec` installation path. REA stays
pinned at `6.4.0`; its existing skill supports Ghidra and is unchanged. Base has
no native analysis engine. Work installs neither Ghidra nor REA, adds only Cua
MCP, and preserves existing local servers and personal leftovers.

To adopt this change on a Personal Mac, back up any local customizations to the
`rea` entry in `~/.pi/agent/mcp.json`, then run:

```sh
./dot diff       # Review the MCP change first
./dot init       # Install Ghidra/runtimes, apply config, run REA's Ghidra doctor
./dot doctor     # Local checks only; does not download or start REA
```

Restart/reconnect Pi's MCP server after adoption. `dot doctor` checks the
headless launcher, application metadata, host-native decompiler, and Mise Java;
`dot init` runs the pinned REA provider doctor for compatibility checks. Neither
check proves decompilation of a real target: test with an explicitly selected
binary separately. See [REA's Ghidra prerequisites](https://github.com/morluto/rea/blob/rea-agents-6.4.0/docs/installation.md#ghidra).

Existing Hopper is left untouched, and neither `brew bundle cleanup` nor any
uninstaller runs. Removing Hopper is optional and manual. For rollback, restore
the prior repository configuration and your backed-up MCP entry, review
`dot diff`, and apply only when ready; Ghidra remains installed until you choose
to remove it. Reverting the configuration does not provide a Hopper licence.

Contributor instructions: [AGENTS.md](AGENTS.md).

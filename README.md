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
Ghostty uses Geist Mono at size 14 with `+ss11` on both Macs; Homebrew owns the
font and chezmoi owns the configuration. Previously installed fonts are kept.

Plannotator reviews use the browser through the shared Pi extension. Herdr
Annotate is no longer installed by dotfiles; on an existing Mac, remove it with
`herdr plugin uninstall annotate`. Saved annotations and review history remain
local and are not deleted. `prefix+o` returns to Herdr's default notification
target shortcut after applying the configuration.

## Zed configuration (Base: both Macs)

Chezmoi manages `~/.config/zed/settings.json` and `keymap.json` on both
Personal and Work, imported from the existing configuration. These are whole-file
configs: back up local customizations and review `./dot diff` before `./dot apply`.
Prompts, custom themes, credentials, sessions, and other local files stay unmanaged.
Zed remains in the existing Base Homebrew bundle; no installers or extensions are
added. The settings reference Catppuccin themes, which must be available separately
on each Mac. To roll back, restore your backed-up files and remove these sources
if you no longer want them managed.

## Herdr desktop appearance (Base: both Macs)

Chezmoi manages `~/.config/herdr-app/layouts/catppuccin.json`, its preview,
`themes/catppuccin-mocha.json`, and the `spaces-icons` / `tabs-graph` mods on
both Personal and Work. The layout always uses Mocha, with a lavender accent,
independent of system appearance. Other layouts and themes remain untouched.

Chezmoi also enables terminal font ligatures (`font_ligatures: true`) in
`~/.config/herdr-app/settings.json` on both Macs. Its modifier preserves every
other setting and refuses malformed JSON or non-object input. Missing or empty
settings start with only this preference. Fonts must support ligatures; Herdr
applies the preference live after `./dot apply`.

The layout and mods come from [MarcozVD/herdr-layout-catppuccin](https://github.com/MarcozVD/herdr-layout-catppuccin)
at `b58f43478fbf874c8be989b3336793f7c98b6d10`; the theme uses the
[official Catppuccin palette](https://github.com/catppuccin/palette).
These are vendored copies, not automatically updated. Mods depend on Herdr's
shipped panels and API; validate them after app upgrades.

Homebrew installs [Herdr desktop](https://formulae.brew.sh/cask/herdr-app) through
`cask "herdr-app"` in Base on both Macs; the cask currently requires Apple Silicon.
The existing `herdr` CLI package/configuration is unchanged. Back up any same-name
custom files before adoption. Review `./dot diff`, then run `./dot init` to install
dependencies and apply configuration, or `./dot apply` for configuration only.
The existing bundle checks in `./dot doctor` cover the cask. With the Herdr desktop
window running, validate and select the layout once on each Mac:

```sh
herdr-app check ~/.config/herdr-app/mods/spaces-icons
herdr-app check ~/.config/herdr-app/mods/tabs-graph
herdr-app do layout.switch '{"name":"catppuccin"}'
herdr-app do app.theme '{"name":"catppuccin-mocha"}'
herdr-app status
```

`spaces-icons` reads project folders, runs read-only Git commands and
`hc machine ls`, and caches icons under Herdr's data folder (using `cp` for PNGs
on macOS). Neither bundled mod accesses the network. Optional Git Graph is not
installed; its button stays hidden. Sessions, credentials, keybindings,
window state, layout clicks/selection, caches, generated typings, and shipped
layouts/mods are not managed. Except for font ligatures, settings and selection
remain local to each Mac.

To stop using it, switch to another layout (`Ctrl+Shift+L`). To stop syncing it,
remove these sources; already-applied files remain until removed manually.

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

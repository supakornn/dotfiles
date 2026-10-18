# Working on these dotfiles

## Ask before changing scope or ownership

For every request to add/update dotfiles or software, establish these decisions
before editing. Ask the user for any answer they have not explicitly supplied:

1. **Scope:** Base (both Macs), Personal only, or Work only?
2. **Owner:** Homebrew (app/standalone CLI), Mise (language runtime/toolchain),
   chezmoi (configuration), native vendor/plugin installer, project-local
   dependency, or manual installation?
3. **Related pieces:** Does this also need configuration, a plugin, skill, MCP
   server, installer step, or doctor check? Which share that scope?

A suitable question is: “Should this be Base, Personal, or Work, and should it be
managed by Homebrew, Mise, chezmoi, a native installer, the project, or manually?” Explain a
recommended owner if the user is unsure. An update does not authorize silently
moving something between profiles or package managers. If retaining an existing
classification, confirm that intent when the request leaves it ambiguous.

Finish this step only when every affected component has an agreed scope/owner.
The currently selected profile on this Mac does not determine repository policy.

## Profile contract

- Personal installs **Base + Personal**; Work installs **Base + Work**. Work never
  inherits Personal. Work currently has no work-only package additions.
- Read `packages/Brewfile.base`, `.personal`, and `.work` for the authoritative
  package lists. Put additions in exactly the agreed bundle, not every bundle.
- The single machine-local selection is `data.profile` in
  `${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/chezmoi.json`: `personal` or `work`.
  `base` is a scope, not a third machine profile. Never infer it from a hostname.
- Shared: shell/editor/terminal configs, font, Herdr plugins, Pi's five packages,
  theme/keybindings/general skills, and Cua CLI/MCP/vendor skill.
- Personal only: REA setup/MCP/skill, Ghidra, GitHub CLI/MCP, alphaXiv, Hugging
  Face, DeepWiki, Cord/Discord presence, and the other personal bundle entries.
  Work adds/updates only Cua MCP, preserves existing local MCPs, and supplies no
  Pi provider/model defaults.
- Microsoft Teams/Outlook/Word/Excel, Zoom, and Chrome remain manual installs
  unless the user explicitly changes that policy.
- When changing a scoped feature, check **installation, templates, ignore rules,
  skills/plugins/MCP, and verification together**. A disabled personal feature
  must not still download, start, or report activity on Work. Cord's specification
  itself is omitted on Work, not merely configured to hide presence.
- Profile switching is refused. Never implement automatic uninstallation or
  local-skill cleanup. Existing personal leftovers can remain and even load;
  doctor reports known leftovers. Profiles are not a security boundary.

## Ownership and layout

- `dot`: the only setup/configuration entry point. `dot diff` previews,
  `dot apply` applies configuration, and `dot init` installs dependencies too.
  Inspection does not install; keep setup logic in this one entry point.
- `packages/Brewfile.*`: Homebrew owns standalone CLIs, build tools, apps, fonts.
  Maven, Gradle, Coursier, uv, and cargo-binstall belong here.
- `home/dot_config/mise/config.toml`: Mise owns Java, Kotlin, Scala, .NET, Node,
  Bun, Python, Rust, and Go; all global declarations are `latest`. Projects may
  pin versions. TypeScript belongs in project dependencies; do not restore pipx.
  Homebrew's own transitive runtime dependencies can remain installed.
- Pi packages, Herdr plugins, and Cua use their native/vendor installers; REA uses
  the approved pinned npx command. These are not language runtimes for Mise.
- `home/`: native chezmoi sources. `.chezmoidata.json` contains shared Pi data;
  `.chezmoiignore` and templates select profile-specific configuration.
- Keep verification scripts and helpers local in temporary sandboxes, outside
  the repository; do not commit a test suite.
- Use native chezmoi/Homebrew/Mise mechanisms. Keep the repository small: Bash,
  native templates, Brewfiles, README, and this file. No Python deployment layer,
  custom backup engine, `docs/` tree, or committed agent working notes.

## Preserve local state

- Keep credentials, OAuth/trust state, sessions, generated locks/caches, Fish
  universal variables, local-only skills/extensions, and `~/.feynman` unmanaged.
  Never capture live secrets or account identity into Git or a PR description.
- Git's modifier preserves existing identity, credential helpers, and unrelated
  settings; `~/.gitconfig.local` provides optional overrides.
- Pi's modifier preserves local provider/model and unknown settings. Personal
  defaults apply only when absent; Work supplies none. MCP's modifier preserves
  existing servers and unknown top-level settings, replacing only complete server
  entries owned by dotfiles in the selected profile. Same-name entries are owned
  by dotfiles; back up local customizations before applying. Invalid JSON or
  non-object configuration is refused rather than replaced.
- btop manages only its theme selection/assets, not other machine preferences.
- Cua owns its version-matched SDK skill and agent links. Preserve existing Cua
  executables/skills; install a missing skill through `cua-driver skills install`.
- REA explicitly uses Ghidra (Homebrew) with the shared Mise Java runtime.
  Existing Hopper in `/Applications/Hopper Disassembler.app` is retained but
  is no longer installed or required by dotfiles.
- Refuse managed-directory symlinks rather than writing into an old repository.
  Keep their targets and local-only data; ask before live migration work.

## Verify and deliver

1. Run `bash -n dot`,
   `sh -n home/modify_dot_gitconfig home/dot_config/btop/modify_btop.conf`,
   `ruby -c` on each Brewfile, and `git diff --check` (also `--cached` if staged).
2. For changed scope/behavior, verify locally in a temporary sandbox: prove both
   inclusion and exclusion, existing-config preservation, and repeatability.
   Keep these verification scripts outside the repository. On macOS Bash 3.2,
   make assertions fail explicitly (`|| fail`); bare `[[ ... ]]` and negated
   commands are not a reliable errexit-based assertion mechanism.
3. Local checks use real chezmoi/jq with temporary HOME/XDG and fake mutating tools.
   Temporary HOME does **not** isolate real Homebrew/app changes. Never run a
   real full init as a supposedly isolated test.
4. Report exactly what was tested versus mocked. Downloads, licences, remote
   authentication, and macOS permissions need separate real-machine validation.
5. Repository editing, committing, or opening a PR does not authorize deployment
   to the live Mac. Ask before live `init`/`apply`, runtime/package installation,
   or replacing existing configs. `--force` skips prompts and makes no backups.
6. Keep instructions in README. When asked for a PR, use a feature branch and
   include the complete Base/Personal/Work map, ownership, migration/rollback
   cautions, commands/tests, limitations, and whether live configuration changed.
   Leave merge and live adoption to the user unless explicitly authorized.

# Neovim: LazyVim

A code-reading and lightweight-editing setup alongside terminal tools and AI agents.
The source lives in `dotfiles/.config/nvim/` and is deployed to `~/.config/nvim`
by the root Mise dotfiles mapping.

## Install and start

The repository's `./bootstrap.sh` deploys this directory and installs Neovim and core
tools through Homebrew/Mise. To redeploy an existing installation, run
`mise dotfiles apply --force --yes` from the repository root; this applies **all**
configured dotfiles, so back up any local-only changes first.

On first launch, lazy.nvim installs plugins and Mason installs configured language
servers. Keep `lazy-lock.json` to preserve the validated plugin versions. Scala needs
its Coursier/Metals installation step below. If Kotlin installation fails at the
JetBrains CDN, use the helper under Maintenance.

Install the JDKs/SDKs and build tools your projects require separately: for example,
JDK 21 for the current JVM setup and a .NET SDK for C#. Existing `~/.dotnet` and
Neovim-local Coursier installations are exposed only to Neovim child processes.

```sh
cd /path/to/project
nvim .
```

Open a trusted project with its dependencies restored. Language servers may index
projects, resolve dependencies, and execute build-system tooling on initial load.

## Everyday shortcuts

Leader is **Space**. Press Space and pause to see the available shortcuts.

| Keys | Action |
| --- | --- |
| Space Space / Space sf | Find files |
| Space sg | Search project text |
| Space e | File explorer |
| Space , | Switch buffers |
| Space so / Space ss | Symbols in the current file |
| gd | Go to definition |
| gr | Find references |
| K | Hover documentation/type information |
| Ctrl-o | Return after a jump |
| Space gd | Git diff picker |
| Space gg | LazyGit |
| Space w | Save |
| Space cf | Manually format |
| Space qq | Quit all windows |
| jj (insert mode) | Exit insert mode |
| Ctrl-h/j/k/l | Navigate Neovim splits and Herdr panes |
| Space ud | Toggle diagnostics |

LazyVim's standard keymaps are retained except for the shortcuts in
`lua/config/keymaps.lua`. This is not a complete port of the previous custom config.

## Languages

| Language | Language server |
| --- | --- |
| Go | gopls |
| Rust | rust-analyzer |
| Java / Maven / Gradle | JDTLS, with Lombok support |
| Kotlin / Gradle | JetBrains kotlin-lsp (alpha) |
| Scala / sbt | Metals 1.6.9 via nvim-metals |
| TypeScript / JavaScript / React | vtsls |
| Vue | vue_ls + vtsls + Vue TypeScript plugin |
| Svelte | svelte + TypeScript plugin |
| Astro | astro + TypeScript plugin |
| C# | OmniSharp + extended definition navigation |
| Assembly | asm-lsp |
| C / C++ | clangd |

Syntax parsers also cover Gradle's Groovy/Kotlin scripts, Maven XML, JSON, YAML,
HTML, CSS, Markdown, and common config files.

### Project prerequisites and limits

- **Java/Kotlin:** Use the project's `./gradlew` / `./mvnw` wrappers and its required JDK.
  Kotlin uses the official JetBrains Kotlin server (currently alpha), with Gradle/Maven
  project import. A real Ktor 3.6.0 / Kotlin 2.3.21 / Gradle 8.14.3 project passed
  cross-file definitions, references, framework hover, and error-diagnostic checks.
  Initial import/indexing can take time. This is not full IntelliJ framework tooling.
- **Scala:** Open a `.scala` file and accept **Import build** for a trusted project.
  Metals downloads dependencies and connects to the build server; first import can take
  time. Scala 3.3.7 / sbt 1.11.7 was tested. Java buffers continue to use JDTLS, not Metals.
  Use `Space me` for Metals commands, `:MetalsImportBuild` to reimport, and `:MetalsDoctor`
  to inspect the project. `Space cf` uses Metals/Scalafmt; keep a project `.scalafmt.conf`
  with its chosen version and dialect. Type diagnostics were verified after saving:
  Metals compiles through its build server on save, even though autoformat/test runners
  are disabled. Scala syntax highlighting and the normal LSP shortcuts are available.
- **C#:** Run `dotnet restore` in your terminal for project dependencies. Neovim exposes
  the existing `~/.dotnet` SDK installation to its child processes if `dotnet` is absent
  from PATH. The shell configuration is unchanged. Navigation was tested on .NET 8 and
  on an ASP.NET Core / .NET 10 project.
- **C/C++:** A `compile_commands.json` gives clangd the project's correct includes/flags.
  For CMake, use `cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`.
- **Frontend:** Restore workspace dependencies. Vue uses the modern Vue 3 integration;
  Vue 2 may need additional configuration.
- **Assembly:** Choose architecture and assembler dialect in a project `.asm-lsp.toml`.
  The current setup is not tailored to a particular instruction set.

## Deliberately disabled

- Formatting on save (`vim.g.autoformat = false`). Manual formatting remains available;
  formatter availability depends on the language and project tooling.
- Debugging, test runners, and extra background linters.
- Inlay hints/code lenses and automatic Rust `cargo check` on save.
- Background plugin-update checks and LuaRocks plugin installation.

## Maintenance

- `:Lazy` — plugin status; update explicitly when wanted.
- `:LazyExtras` — inspect/add upstream integrations. The current language imports are
  declared in `lua/config/lazy.lua`, not managed through a generated extras list.
- `:Mason` — language-server installation status.
- `:LazyHealth` — load plugins and inspect health reports.
- `:checkhealth lazy mason nvim-treesitter` — focused installation checks.
- `:LspInfo` — inspect attached language servers.
- Kotlin installation workaround: Mason's current direct CDN URL fails without a signed
  redirect. `nvim --headless '+luafile ~/.config/nvim/scripts/install-kotlin.lua'` installs
  through JetBrains' official public download host. This changes only the in-memory
  download URL for that installation, not registry files or global package settings.

### Scala installation on another machine

Metals is managed by **nvim-metals/Coursier**, not Mason. On macOS ARM64:

```sh
bash ~/.config/nvim/scripts/install-scala.sh
# Open a Scala file in Neovim, then run :MetalsInstall and restart Neovim.
```

The installer pins Coursier 2.1.26 and verifies the official release asset's SHA-256.
It installs `cs` under Neovim's data directory (`~/.local/share/nvim/tools` by default).
Neovim adds that directory to its own PATH only if `cs` is otherwise unavailable;
no shell configuration is changed. The Metals version is pinned in `lua/plugins/scala.lua`.
On macOS the server uses the existing JDK 21; other platforms need a suitable JDK and
[Coursier installation](https://get-coursier.io/docs/cli-installation).

`lazy-lock.json` pins the installed plugin commits. Preserve it when deploying or updating.

## Validation history

The following checks were run on the original macOS ARM64 machine; the demo projects,
logs, caches, and local backups are not bundled with this configuration.

Headless sample-file checks passed for all 14 requested language/framework cases:
server initialization plus syntax parsing. Definition requests passed for Go, Rust,
TypeScript, Java, Kotlin, C#, C, C++, Svelte, Astro, and Vue (via vtsls).
File picker results, shortcuts, and saving without reformatting were also checked.
Separate real-project proofs were created and verified in
`~/Documents/neovim-ktor-demo` and `~/Documents/neovim-dotnet-demo`, using
`scripts/verify.sh` and `proof/verification.txt`. Those demo projects are not tracked
here and may no longer be present locally. These checks do not substitute for trying
other project layouts or checking the interactive terminal appearance.

Scala was additionally checked with a real sbt fixture in `/tmp/nvim-scala-proof/project`:
build import, cross-file definition, references, hover, completion, Scalafmt edits,
syntax parsing, standard keymaps, and saved-error diagnostics (including clearing after
restoration). The fixture and headless proof script are temporary, not a permanent demo.
Java exclusion, disabled autoformat, and absence of a debugger were also checked.
The same Scala proof passed again with `XDG_CONFIG_HOME` pointing at the repository's
`dotfiles/.config` directory after migration.

Focused health checks have no errors. Remaining warnings are optional missing
PHP/Composer/Julia/LuaRocks runtimes and an empty pre-existing native package directory.
None are required by the configured languages.

## Rollback

The previous repository configuration remains available in Git history. To recover it
without discarding other work, choose the revision before the LazyVim migration and
extract `dotfiles/.config/nvim` to a separate directory before deploying it. Back up
your current local config first.

### Original-machine backups

These paths describe backups on the machine where the setup was validated; they are
not created automatically by bootstrap on another machine.

The exact pre-change config, plugin data, state, and cache are backed up under:

`~/.local/state/nvim-backups/20261014-213813/{config,data,state,cache}`

Close Neovim before restoring. To restore only the previous config (its plugin manager
can reinstall the old plugins), keeping this trial for comparison:

```sh
mv ~/.config/nvim ~/.config/nvim-lazyvim-trial-$(date +%Y%m%d-%H%M%S)
cp -R ~/.local/state/nvim-backups/20261014-213813/config ~/.config/nvim
```

The other backup directories can restore the corresponding `~/.local/share/nvim`,
`~/.local/state/nvim`, and `~/.cache/nvim` trees if an exact full rollback is needed.
Move the trial directories aside first rather than merging backup trees into them.

## Sources

- https://www.lazyvim.org/installation
- https://www.lazyvim.org/configuration/general
- https://www.lazyvim.org/extras
- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/omnisharp.lua
- https://github.com/vuejs/language-tools/wiki/Neovim
- https://github.com/bergercookie/asm-lsp
- https://www.lazyvim.org/extras/lang/scala
- https://github.com/scalameta/nvim-metals
- https://scalameta.org/metals/docs/editors/vim/
- https://get-coursier.io/docs/cli-installation

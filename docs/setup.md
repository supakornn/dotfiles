# Setup notes

## Package installation

Run `--apply` from an interactive terminal. It prepares Homebrew, Mise, and a
Mise-managed Python before running the deployment safety checks. Python is installed
explicitly, so this also works with Mise's automatic installation disabled. These
prerequisite installations can happen even if the later safety checks block
changes. Dotfiles are not replaced to make Python available.

Homebrew's installer and some apps require administrator approval; Tailscale's App
Store installation may require sign-in. `--skip-packages` requires Homebrew and
Mise already installed and skips Homebrew and agent package installation, but
still prepares Python, configured runtimes, and Herdr plugins through Mise.

Hopper is installed through Homebrew at `/Applications/Hopper Disassembler.app`.
If its executable already exists there, bootstrap preserves it instead of replacing
it with Homebrew's demo build. Licence activation remains an interactive step.

Bootstrap uses Homebrew's `--no-upgrade` unless you pass `--upgrade`. Homebrew may
still upgrade dependencies required by a new installation. Package changes are
machine-wide, even when testing with a temporary home directory.

After deployment preflight passes, bootstrap adds the OpenCode tap and trusts only
`anomalyco/tap/opencode-v2`, the formula declared in the Brewfile. It does not trust
an entire tap. Review this declaration before running `--apply`.

## Deployment and recovery

`--force` backs up conflicting destinations before deploying. Backups have a
manifest and a private parent directory (mode 700); they may contain sensitive
settings. Restore files manually if needed. They do not undo package changes.

Unfinished Mise operations block deployment. Inspect `mise dot history --pending`
and review saved state before recovering; do not blindly restore an old operation.
Legacy directory symlinks also need manual migration before narrower mappings can
be applied.

Pi's managed files and btop's config are copied rather than symlinked, so runtime
writes cannot modify the tracked source. Redeployment resets those files to the
repo versions. Edit the repo to retain intentional changes. Fish and skill
subdirectories use `symlink-each`, preserving unrelated local entries.

## MCP prerequisites

- **GitHub:** run `gh auth login`. Pi obtains the token with `gh auth token`; no
  token is stored in the repo.
- **Cua Driver:** bootstrap uses the [official installer](https://cua.ai/docs/cua-driver/quickstart)
  when `~/.local/bin/cua-driver` is missing. It does not edit shell startup files or
  reinstall an existing executable. On first use, approve Accessibility and Screen
  Recording for CuaDriver in System Settings; bootstrap cannot grant these.
- **Pi packages:** installed from the tracked settings. Existing npm packages are
  retained rather than upgraded on every run.
- **REA:** prepared through Node/npx, pinned to `rea-agents@6.4.0`. The Hopper
  integration uses `/Applications/Hopper Disassembler.app`.

MCP configuration is in [`dotfiles/.pi/agent/mcp.json`](../dotfiles/.pi/agent/mcp.json).
Bootstrap installs the tools, not credentials. GitHub/Pi sign-in, remote MCP OAuth,
app licences, and macOS permissions remain interactive. These are approvals and
account setup, not additional software installation commands.

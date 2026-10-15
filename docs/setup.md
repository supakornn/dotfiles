# Setup notes

## Package installation

Run `--apply` from an interactive terminal: some apps require an administrator
password, and Tailscale's App Store installation may require sign-in.

Bootstrap uses Homebrew's `--no-upgrade` unless you pass `--upgrade`. Homebrew may
still upgrade dependencies required by a new installation. Package changes are
machine-wide, even when testing with a temporary home directory.

If Homebrew rejects a package from an untrusted tap, review it and approve that
specific package. For OpenCode:

```sh
brew trust --formula anomalyco/tap/opencode-v2
```

Bootstrap does not grant Homebrew tap trust automatically.

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
- **Cua Driver:** install the executable at `~/.local/bin/cua-driver`.
- **REA:** launched through Node/npx, pinned to `rea-agents@6.4.0`. The optional
  Hopper integration expects `~/Applications/Hopper Disassembler.app`; adjust
  `HOPPER_LAUNCHER_PATH` in the MCP config if installed elsewhere.

MCP configuration is in [`dotfiles/.pi/agent/mcp.json`](../dotfiles/.pi/agent/mcp.json).
These external tools and their credentials are not provisioned by dotfile deployment.

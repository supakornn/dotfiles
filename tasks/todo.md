# Safe deployment tasks

- [x] Narrow state-sensitive mappings; prove local-only files survive deployment.
- [x] Capture portable MCP definitions without credentials.
- [x] Test and implement preview-first bootstrap with private backups and explicit flags.
- [x] Repeat isolated deployment/runtime checks and document remaining blockers.

## Results and boundaries

- 17 automated tests cover CLI flags, package/preflight failure boundaries, backups,
  path validation, portable MCP configuration, and real isolated Mise deployment.
- An inverted force guard was caught by the conflict regression test.
- Actual `bootstrap.sh --apply --force --skip-packages` exited 0 in `/tmp/dtf-612bhqbj`.
  All 23 mappings were applied; synthetic local auth, skills and Fish variables
  survived. Runtime/build-tool commands succeeded with reused runtime binaries.
- Herdr plugins installed; auto-title restart was tolerated with no sandbox server.
  Use a short sandbox path: Herdr's Unix socket fails with long macOS temp paths.
- Real-home preview exits 0 and does not deploy. Real-home preflight correctly
  blocks on unfinished operation 2 from October 12; no automatic recovery ran.
- Vorssaint still needs interactive administrator approval. Remote MCP auth and
  clean-machine provisioning are not claimed as verified. No real-home deployment
  or commit was performed.

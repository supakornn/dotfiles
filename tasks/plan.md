# Plan: safe local dotfile deployment

Approved direction: preserve local credentials/state, capture portable configuration,
and make package upgrades and conflicting-file replacement explicit.

## Tasks
1. Narrow Pi, agents, Fish, and Mise mappings; copy mutable Pi/btop configuration.
   Acceptance: credentials, local-only skills, and Fish universal variables survive
   an isolated deployment and a second apply is idempotent.
2. Capture the active MCP server set without literal credentials or personal paths.
   Acceptance: DeepWiki/REA present; GitHub uses gh auth; Cua uses a home-relative
   executable; REA's optional Hopper override is documented rather than hard-coded.
3. Add preview-first bootstrap, explicit apply/upgrade/force flags, and private
   backups before deployment. Report prerequisites, tap trust and interactive
   installation requirements without broadening trust or bypassing authentication.
   Acceptance: mocked tests prove preview performs no installs, no-upgrade is the
   default, conflicts require force, and backup failure prevents deployment.
4. Run automated and isolated runtime/deployment tests; document unresolved
   administrator approvals and old interrupted-operation state.

## Boundaries
- Do not force-apply to the real home or commit.
- Do not store secrets in the repository or restore old failed operations blindly.
- Reuse existing runtime binaries in isolation; this is not a clean-machine proof.
- Prefer a small Python standard-library helper over shell parsing of JSON.

## Verification
`python3 -m unittest discover -s tests -v`, `bash -n bootstrap.sh`,
`git diff --check`, isolated Mise apply/status/idempotence and state-preservation tests.

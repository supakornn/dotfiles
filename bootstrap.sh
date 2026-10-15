#!/usr/bin/env bash
# Preview first. Deployment and package changes require --apply.
set -euo pipefail

usage() {
  echo 'Usage: ./bootstrap.sh [--apply] [--force] [--upgrade] [--skip-packages]'
  echo 'Default: preview only. --force backs up conflicting dotfiles before replacement.'
  echo '--upgrade allows package upgrades; --skip-packages uses already-installed packages.'
}
apply=false; force=false; upgrade=false; skip_packages=false
for arg in "$@"; do
  case "$arg" in
    --apply) apply=true ;;
    --force) force=true ;;
    --upgrade) upgrade=true ;;
    --skip-packages) skip_packages=true ;;
    --help|-h) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
if ! "$apply" && { "$force" || "$upgrade" || "$skip_packages"; }; then
  echo '--force, --upgrade and --skip-packages require --apply.' >&2
  exit 2
fi
if [[ "$(uname)" != Darwin ]]; then
  echo 'This bootstrap supports macOS only.' >&2
  exit 1
fi
for tool in brew mise; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing $tool. Install Homebrew (https://brew.sh/), then run: brew install mise" >&2
    exit 1
  fi
done
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export HOMEBREW_NO_AUTO_UPDATE=1
if ! "$apply"; then
  echo 'PREVIEW ONLY: no packages, plugins, or dotfiles will be installed.'
  HOMEBREW_BUNDLE_NO_UPGRADE=1 brew bundle check --verbose --file="$repo_dir/Brewfile" || true
  # --force only describes conflict replacements here; --dry-run prevents writes.
  mise -C "$repo_dir" dotfiles apply --dry-run --force
  echo 'Review the repository before trusting its config: mise trust '"$repo_dir/mise.toml"
  echo 'To deploy: ./bootstrap.sh --apply (add --force only after reviewing conflicts).'
  exit 0
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo 'Python 3.8+ is required for private backups. Run via: mise exec python@latest -- ./bootstrap.sh --apply' >&2
  exit 1
fi
# Trust only this explicitly requested repository, never entire Homebrew taps.
mise trust "$repo_dir/mise.toml"
deploy_command=(python3 "$repo_dir/scripts/deploy.py")
if "$force"; then deploy_command+=(--force); fi
"${deploy_command[@]}" --check
if ! "$skip_packages"; then
  echo 'Package installation may prompt for administrator access and App Store sign-in.'
  echo 'Review tap trust if needed: brew trust --formula anomalyco/tap/opencode-v2'
  bundle_command=(brew bundle install --file="$repo_dir/Brewfile")
  if ! "$upgrade"; then bundle_command+=(--no-upgrade); fi
  if ! "${bundle_command[@]}"; then
    echo 'Package installation failed; dotfiles were not deployed.' >&2
    echo 'Retry from an interactive terminal after reviewing password/sign-in and tap-trust errors.' >&2
    exit 1
  fi
fi
"${deploy_command[@]}"
mise -C "$repo_dir" install
mise -C "$repo_dir" run build-bat-cache
mise -C "$repo_dir" run install-herdr-plugins

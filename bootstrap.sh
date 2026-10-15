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
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export HOMEBREW_NO_AUTO_UPDATE=1

# An existing Homebrew installation may not yet be on a fresh shell's PATH.
activate_homebrew() {
  if command -v brew >/dev/null 2>&1; then return; fi
  local brew_env
  if [[ -x /opt/homebrew/bin/brew ]]; then
    brew_env="$(/opt/homebrew/bin/brew shellenv)"
    eval "$brew_env"
  elif [[ -x /usr/local/bin/brew ]]; then
    brew_env="$(/usr/local/bin/brew shellenv)"
    eval "$brew_env"
  fi
}
activate_homebrew
if ! command -v brew >/dev/null 2>&1; then
  if ! "$apply" || "$skip_packages"; then
    echo 'Homebrew is missing. Run ./bootstrap.sh --apply to install prerequisites.' >&2
    exit 1
  fi
  echo 'Installing Homebrew using its official installer; administrator approval may be required.'
  installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  /bin/bash -c "$installer"
  activate_homebrew
  if ! command -v brew >/dev/null 2>&1; then
    echo 'Homebrew is still unavailable. Complete its installation and retry.' >&2
    exit 1
  fi
fi
if ! command -v mise >/dev/null 2>&1; then
  if ! "$apply" || "$skip_packages"; then
    echo 'Mise is missing. Run ./bootstrap.sh --apply to install prerequisites.' >&2
    exit 1
  fi
  brew install mise
fi
if ! "$apply"; then
  echo 'PREVIEW ONLY: no packages, plugins, or dotfiles will be installed.'
  HOMEBREW_BUNDLE_NO_UPGRADE=1 brew bundle check --verbose --file="$repo_dir/Brewfile" || true
  # --force only describes conflict replacements here; --dry-run prevents writes.
  mise -C "$repo_dir" dotfiles apply --dry-run --force
  echo 'Review the repository before trusting its config: mise trust '"$repo_dir/mise.toml"
  echo 'Apply also prepares language runtimes, agent dependencies, and Herdr plugins.'
  echo 'To deploy: ./bootstrap.sh --apply (add --force only after reviewing conflicts).'
  exit 0
fi
# Trust only this explicitly requested repository, never entire Homebrew taps.
mise trust "$repo_dir/mise.toml"
# Prepare Python explicitly, even if automatic installation is disabled in Mise.
# This does not deploy or change the user's global runtime configuration.
mise -C "$repo_dir" install python@latest
deploy_command=(mise -C "$repo_dir" exec python@latest -- python "$repo_dir/scripts/deploy.py")
if "$force"; then deploy_command+=(--force); fi
"${deploy_command[@]}" --check
if ! "$skip_packages"; then
  echo 'Package installation may prompt for administrator access and App Store sign-in.'
  # --apply approves this repo's package declarations, not every package in a tap.
  brew tap anomalyco/tap
  brew trust --formula anomalyco/tap/opencode-v2
  bundle_command=(brew bundle install --file="$repo_dir/Brewfile")
  if ! "$upgrade"; then bundle_command+=(--no-upgrade); fi
  # Preserve an existing (possibly licensed) Hopper rather than replace it with the demo.
  if [[ -x "/Applications/Hopper Disassembler.app/Contents/MacOS/hopper" ]]; then
    export HOMEBREW_BUNDLE_CASK_SKIP="${HOMEBREW_BUNDLE_CASK_SKIP:+$HOMEBREW_BUNDLE_CASK_SKIP }hopper-disassembler"
  fi
  if ! "${bundle_command[@]}"; then
    echo 'Package installation failed; dotfiles were not deployed.' >&2
    echo 'Retry from an interactive terminal after reviewing the package error above.' >&2
    exit 1
  fi
fi
"${deploy_command[@]}"
mise -C "$repo_dir" install
if ! "$skip_packages"; then
  mise -C "$repo_dir" run install-agent-tools
fi
mise -C "$repo_dir" run build-bat-cache
mise -C "$repo_dir" run install-herdr-plugins
echo 'Setup finished. Account sign-ins, app licences, and macOS permission approvals remain yours to complete.'

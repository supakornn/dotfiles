#!/usr/bin/env bash
# Bootstrap this macOS setup with Homebrew and Mise.
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This bootstrap script supports macOS only." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
if [[ -x /usr/local/bin/brew ]]; then eval "$(/usr/local/bin/brew shellenv)"; fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
brew bundle --file="$repo_dir/Brewfile"

mise trust "$repo_dir/mise.toml"
mise -C "$repo_dir" dotfiles apply --force --yes
mise -C "$repo_dir" install
mise -C "$repo_dir" run install-herdr-plugins

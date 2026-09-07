#!/usr/bin/env bash
# Bootstrap selected Stow packages on macOS.
# Usage: ./install.sh common [personal]
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This bootstrap script supports macOS only." >&2
  exit 1
fi

profiles=("$@")
if [[ ${#profiles[@]} -eq 0 ]]; then
  echo "Usage: $0 common [personal]" >&2
  exit 1
fi

for profile in "${profiles[@]}"; do
  case "$profile" in common|personal) ;; *) echo "Unknown profile: $profile" >&2; exit 1 ;; esac
done

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Install Xcode Command Line Tools, finish the macOS prompt, then rerun this script:"
  echo "  xcode-select --install"
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
if [[ -x /usr/local/bin/brew ]]; then eval "$(/usr/local/bin/brew shellenv)"; fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for profile in "${profiles[@]}"; do
  brew bundle --file="$repo_dir/Brewfile.$profile" --no-lock
  stow --dir="$repo_dir" --target="$HOME" --restow "$profile"
done

echo "Done. Herdr was installed but not started; run 'herdr' yourself when needed."

#!/usr/bin/env bash
# Bootstrap the selected macOS profile with Homebrew and Chezmoi.
set -euo pipefail

profile="${1:-work}"
case "$profile" in
  work|personal) ;;
  *) echo "Usage: $0 [work|personal]" >&2; exit 1 ;;
esac

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
brew install chezmoi
brew bundle --file="$repo_dir/Brewfile.common"
if [[ "$profile" == "personal" ]]; then
  brew bundle --file="$repo_dir/Brewfile.ai"
  brew bundle --file="$repo_dir/Brewfile.personal"
fi

mkdir -p "$HOME/.config/chezmoi"
cat > "$HOME/.config/chezmoi/chezmoi.toml" <<EOF
sourceDir = "$repo_dir/chezmoi"

[data]
profile = "$profile"
EOF

# --force replaces the old Stow symlinks with Chezmoi-managed files.
chezmoi apply --force --verbose

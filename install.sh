#!/usr/bin/env bash
# Bootstrap selected Stow packages on macOS.
# Usage: ./install.sh [--backup-existing] common [personal]
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This bootstrap script supports macOS only." >&2
  exit 1
fi

backup_existing=false
profiles=()
for argument in "$@"; do
  case "$argument" in
    --backup-existing) backup_existing=true ;;
    common|personal) profiles+=("$argument") ;;
    *) echo "Unknown option or profile: $argument" >&2; exit 1 ;;
  esac
done

if [[ ${#profiles[@]} -eq 0 ]]; then
  echo "Usage: $0 [--backup-existing] common [personal]" >&2
  exit 1
fi

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
backup_dir=""
bundle_failed=false
setup_local_file() {
  local source="$1" target="$2" name="$3" temporary
  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" ]]; then
    temporary="${target}.migrate-$$"
    cp "$target" "$temporary"
    rm "$target"
    mv "$temporary" "$target"
    echo "Migrated $name config to local settings"
  elif [[ ! -e "$target" ]]; then
    cp "$source" "$target"
    echo "Created local $name config from shared defaults"
  fi
}

setup_nvim_lockfile() {
  local source target config_dir temporary
  source="$repo_dir/common/.config/nvim/lazy-lock.json"
  config_dir="$HOME/.config/nvim"
  target="$config_dir/lazy-lock.json"

  if [[ -L "$config_dir" ]]; then
    temporary="$(mktemp)"
    cp "$target" "$temporary"
    rm "$config_dir"
    mkdir -p "$config_dir"
    mv "$temporary" "$target"
    echo "Migrated Neovim plugin lockfile to local settings"
  else
    setup_local_file "$source" "$target" "Neovim plugin lockfile"
  fi
}

backup_legacy_ghostty_configs() {
  local relative target destination
  for relative in \
    "Library/Application Support/com.mitchellh.ghostty/config" \
    "Library/Application Support/com.mitchellh.ghostty/config.ghostty"; do
    target="$HOME/$relative"
    if [[ -f "$target" || -L "$target" ]]; then
      if [[ -z "$backup_dir" ]]; then
        backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
      fi
      destination="$backup_dir/$relative"
      mkdir -p "$(dirname "$destination")"
      mv "$target" "$destination"
      echo "Backed up legacy Ghostty config: $target"
    fi
  done
}

backup_conflicts() {
  local profile source relative target destination
  profile="$1"
  while IFS= read -r -d '' source; do
    relative="${source#"$repo_dir/$profile/"}"
    target="$HOME/$relative"
    # Existing Stow links are already managed; only back up regular files.
    if [[ ! -L "$target" && -e "$target" ]]; then
      if [[ -z "$backup_dir" ]]; then
        backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
      fi
      destination="$backup_dir/$relative"
      mkdir -p "$(dirname "$destination")"
      mv "$target" "$destination"
      echo "Backed up $target"
    fi
  done < <(find "$repo_dir/$profile" -type f -print0)
}

for profile in "${profiles[@]}"; do
  if ! brew bundle --file="$repo_dir/Brewfile.$profile"; then
    echo "Homebrew installation failed for $profile; applying its dotfiles anyway." >&2
    bundle_failed=true
  fi
  if [[ "$profile" == "common" ]]; then
    backup_legacy_ghostty_configs
    setup_local_file "$repo_dir/common/.config/herdr/config.toml" "$HOME/.config/herdr/config.toml" "Herdr"
    setup_local_file "$repo_dir/common/.config/plannotator-tui/config.toml" "$HOME/.config/plannotator-tui/config.toml" "Plannotator TUI"
    setup_local_file "$repo_dir/common/.config/btop/btop.conf" "$HOME/.config/btop/btop.conf" "btop"
    setup_nvim_lockfile
  fi
  if "$backup_existing"; then
    backup_conflicts "$profile"
  fi
  if [[ "$profile" == "common" ]]; then
    stow --dir="$repo_dir" --target="$HOME" --restow --ignore='^\.config/(herdr/config\.toml|btop/btop\.conf|nvim/lazy-lock\.json)$' "$profile"
  else
    stow --dir="$repo_dir" --target="$HOME" --restow "$profile"
  fi
done


if [[ -n "$backup_dir" ]]; then
  echo "Existing files were backed up to $backup_dir"
fi

echo "Done. Herdr was installed but not started; run 'herdr' yourself when needed."
if "$bundle_failed"; then
  exit 1
fi

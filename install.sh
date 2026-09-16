#!/usr/bin/env bash
# Backward-compatible entrypoint; Chezmoi owns dotfiles now.
set -euo pipefail

profile="${1:-work}"
case "$profile" in
  common) profile=work ;;
  personal) profile=personal ;;
  work) ;;
  *) echo "Usage: $0 [work|personal]" >&2; exit 1 ;;
esac

exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bootstrap.sh" "$profile"

#!/usr/bin/env bash
# Compatibility shim; all setup lives in dot.
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
case "${1:-}" in
  '') exec "$repo/dot" diff ;;
  --apply) shift; exec "$repo/dot" init "$@" ;;
  --help|-h) echo './bootstrap.sh previews; --apply [dot init options] sets up the Mac.' ;;
  *) echo 'Use ./bootstrap.sh --apply [dot init options], or ./dot --help.' >&2; exit 2 ;;
esac

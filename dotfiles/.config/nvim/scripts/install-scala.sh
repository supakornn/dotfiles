#!/usr/bin/env bash
# Install pinned Coursier locally for nvim-metals (current macOS ARM64 setup).
set -euo pipefail

if [[ "$(uname -sm)" != "Darwin arm64" ]]; then
  echo "This installer targets macOS ARM64; see https://get-coursier.io/docs/cli-installation for other platforms." >&2
  exit 1
fi

tools="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/tools"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fL --retry 2 \
  https://github.com/coursier/coursier/releases/download/v2.1.26/cs-aarch64-apple-darwin.gz \
  -o "$tmp/cs.gz"
# Matches the official GitHub release asset's SHA-256 digest.
expected=8e4d36aa2565276f262af073f0999399e4c2f920f2fe436bb0ae67665eb505e9
actual=$(shasum -a 256 "$tmp/cs.gz" | awk '{print $1}')
if [[ "$actual" != "$expected" ]]; then
  echo "Coursier download checksum mismatch; refusing to install." >&2
  exit 1
fi
gzip -dc "$tmp/cs.gz" > "$tmp/cs"
chmod +x "$tmp/cs"
mkdir -p "$tools"
mv "$tmp/cs" "$tools/cs"
echo "Installed Coursier 2.1.26 at $tools/cs (Neovim-only PATH fallback)."
echo "Open a Scala file in Neovim and run :MetalsInstall to install Metals."

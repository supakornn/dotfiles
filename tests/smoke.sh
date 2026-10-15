#!/usr/bin/env bash
# Real chezmoi, temporary homes. Never installs packages or launches services.
set -euo pipefail
fail() { echo "FAIL near test line ${BASH_LINENO[0]}" >&2; exit 1; }
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v chezmoi >/dev/null
command -v jq >/dev/null
sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT
mkdir "$sandbox/bin"
export TEST_BIN="$sandbox/bin" TEST_LOG="$sandbox/calls"
# Fake only mutating tools. chezmoi and jq remain real, with temporary HOME/XDG.
cat > "$TEST_BIN/fake" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
tool="${0##*/}"
printf '%s %s\n' "$tool" "$*" >> "$TEST_LOG"
[[ "${FAIL_STAGE:-}" != "$tool" ]] || exit 19
case "$tool" in
  brew)
    if [[ "$*" == 'bundle check '* && " $* " != *' --no-upgrade '* ]]; then exit 91; fi ;;
  mise)
    if [[ " $* " == *' exec '* ]]; then
      while [[ "$1" != -- ]]; do shift; done
      shift; exec "$@"
    fi ;;
  pi)
    name="${2#npm:}"
    mkdir -p "$HOME/.pi/agent/npm/node_modules/$name"
    jq -n --arg name "$name" '{name:$name,version:"retained"}' > "$HOME/.pi/agent/npm/node_modules/$name/package.json" ;;
  curl)
    [[ "$*" == '-fsSL https://cua.ai/driver/install.sh' ]] || exit 90
    echo 'mkdir -p "$HOME/.local/bin"; cp "$TEST_BIN/fake" "$HOME/.local/bin/cua-driver"' ;;
  cua-driver)
    if [[ "$*" == 'skills install' ]]; then
      mkdir -p "$HOME/.cua-driver/skills/cua-driver" "$HOME/.agents/skills"
      echo 'vendor skill' > "$HOME/.cua-driver/skills/cua-driver/SKILL.md"
      [[ -L "$HOME/.agents/skills/cua-driver" ]] || ln -s "$HOME/.cua-driver/skills/cua-driver" "$HOME/.agents/skills/cua-driver"
    fi ;;
esac
SH
chmod +x "$TEST_BIN/fake"
for tool in brew mise pi npx curl bat herdr; do ln -s fake "$TEST_BIN/$tool"; done
export PATH="$TEST_BIN:$PATH"
for selected in personal work; do
  export HOME="$sandbox/$selected"
  export XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$HOME/.local/share"
  export XDG_CACHE_HOME="$HOME/.cache" XDG_STATE_HOME="$HOME/.local/state"
  mkdir -p "$HOME/.config/btop" "$HOME/.pi/agent/sessions" "$HOME/.agents/skills/local-only"
  # SDK content belongs to Cua, not chezmoi, including its existing symlink.
  mkdir -p "$HOME/.cua-driver/skills/cua-driver"
  echo 'vendor skill' > "$HOME/.cua-driver/skills/cua-driver/SKILL.md"
  ln -s "$HOME/.cua-driver/skills/cua-driver" "$HOME/.agents/skills/cua-driver"
  echo 'keep' > "$HOME/.agents/skills/local-only/SKILL.md"
  printf '[user]\n  name = Local Override\n' > "$HOME/.gitconfig.local"
  printf '[user]\n  email = existing@example.invalid\n[credential]\n  helper = local-helper\n' > "$HOME/.gitconfig"
  echo 'keep' > "$HOME/.pi/agent/auth.json"
  echo 'session' > "$HOME/.pi/agent/sessions/local.json"
  mkdir -p "$HOME/.feynman" "$HOME/.config/fish"
  for file in .pi/agent/mcp-auth.json .pi/agent/trust.json .agents/.skill-lock.json .feynman/auth.json .config/fish/fish_variables; do
    echo 'local state' > "$HOME/$file"
  done
  printf 'color_theme = "Default"\nupdate_ms = 987\n# local preference\n' > "$HOME/.config/btop/btop.conf"
  config="$XDG_CONFIG_HOME/chezmoi/chezmoi.json"
  chezmoi --source "$repo/home" --config "$config" --destination "$HOME" init --promptChoice "Profile=$selected"
  "$repo/dot" apply --force
  [[ "$(git config --file "$HOME/.gitconfig" --get user.email)" == existing@example.invalid ]] || fail
  [[ "$(git config --file "$HOME/.gitconfig" --get credential.helper)" == local-helper ]] || fail
  managed="$(chezmoi --source "$repo/home" --config "$config" --destination "$HOME" managed)"
  ! grep -Fq '.config/nvim/.pi' <<< "$managed" || fail
  [[ "$(jq -r '.data.profile' "$config")" == "$selected" ]] || fail
  [[ "$(jq '.packages | length' "$HOME/.pi/agent/settings.json")" == 5 ]] || fail
  [[ "$(jq -r '.theme' "$HOME/.pi/agent/settings.json")" == catppuccin-mocha ]] || fail
  [[ "$(jq -r '.mcpServers | has("cua-driver")' "$HOME/.pi/agent/mcp.json")" == true ]] || fail
  if [[ "$selected" == work ]]; then
    [[ "$(jq '.mcpServers | length' "$HOME/.pi/agent/mcp.json")" == 1 ]] || fail
    jq -e 'has("defaultProvider") == false and has("defaultModel") == false' "$HOME/.pi/agent/settings.json" >/dev/null
    [[ ! -e "$HOME/.agents/skills/reverse-engineer-anything" ]] || fail
    [[ ! -e "$HOME/.config/nvim/lua/plugins/cord.lua" ]] || fail
  else
    [[ "$(jq '.mcpServers | length' "$HOME/.pi/agent/mcp.json")" == 6 ]] || fail
    [[ -f "$HOME/.agents/skills/reverse-engineer-anything/SKILL.md" ]] || fail
    [[ -f "$HOME/.config/nvim/lua/plugins/cord.lua" ]] || fail
  fi
  grep -q '^color_theme = "catppuccin_mocha"$' "$HOME/.config/btop/btop.conf"
  grep -q '^update_ms = 987$' "$HOME/.config/btop/btop.conf"
  grep -q '^# local preference$' "$HOME/.config/btop/btop.conf"
  [[ "$(grep -c '= "latest"' "$HOME/.config/mise/config.toml")" == 9 ]] || fail
  for tool in java kotlin scala dotnet node bun python rust go; do
    grep -q "^$tool = \"latest\"$" "$HOME/.config/mise/config.toml"
  done
  jq '. + {defaultProvider:"local",defaultModel:"chosen",localState:42}' "$HOME/.pi/agent/settings.json" > "$sandbox/settings"
  mv "$sandbox/settings" "$HOME/.pi/agent/settings.json"
  "$repo/dot" apply --force
  jq -e '.defaultProvider == "local" and .defaultModel == "chosen" and .localState == 42' "$HOME/.pi/agent/settings.json" >/dev/null
  "$repo/dot" apply
  [[ -z "$("$repo/dot" status)" ]] || fail
  [[ "$(cat "$HOME/.pi/agent/auth.json")" == keep ]] || fail
  [[ "$(cat "$HOME/.pi/agent/sessions/local.json")" == session ]] || fail
  grep -q 'name = Local Override' "$HOME/.gitconfig.local"
  [[ -f "$HOME/.agents/skills/local-only/SKILL.md" && -L "$HOME/.agents/skills/cua-driver" ]] || fail
  "$HOME/.local/bin/dot" --help >/dev/null
  if "$repo/dot" init --profile "$([[ "$selected" == work ]] && echo personal || echo work)" > "$sandbox/switch.log" 2>&1; then
    echo 'Profile switch unexpectedly succeeded' >&2; exit 1
  fi
  grep -q 'Profile switching' "$sandbox/switch.log"
  # First adoption: old global Java config, local Pi choices, and preinstalled tools.
  pi install npm:pi-web-access
  expected_installs=4
  if [[ "$selected" == work ]]; then
    while IFS= read -r package; do pi install "$package"; done < <(jq -r '.packages[]' "$HOME/.pi/agent/settings.json")
    mkdir -p "$HOME/.local/bin"
    cp "$TEST_BIN/fake" "$HOME/.local/bin/cua-driver"
    expected_installs=0
  fi
  printf '[tools]\njava = "temurin-21"\n' > "$HOME/.config/mise/config.toml"
  rm "$config"
  : > "$TEST_LOG"
  "$repo/dot" init --profile "$selected" --force > "$sandbox/init.log" 2>&1
  [[ "$(jq -r '.data.profile' "$config")" == "$selected" ]] || fail
  [[ "$(grep -c '= "latest"' "$HOME/.config/mise/config.toml")" == 9 ]] || fail
  grep -q 'Brewfile.base' "$TEST_LOG"
  grep -q "Brewfile.$selected" "$TEST_LOG"
  [[ "$(grep -c '^pi install ' "$TEST_LOG" || true)" == "$expected_installs" ]] || fail
  if [[ "$selected" == work ]]; then ! grep -q '^curl ' "$TEST_LOG" || fail
  else grep -q '^curl ' "$TEST_LOG"; fi
  grep -q 'mise .*--yes install' "$TEST_LOG"
  grep -q 'herdr plugin install --yes plannotator/herdr-annotate' "$TEST_LOG"
  grep -q 'herdr plugin install --yes kryptamine/herdr-auto-title' "$TEST_LOG"
  ! grep '^brew bundle install ' "$TEST_LOG" | grep -v -- --no-upgrade || fail
  if [[ "$selected" == work ]]; then
    ! grep -Eq 'Brewfile.personal|^npx |rea-agents' "$TEST_LOG" || fail
  else
    grep -q '^npx --yes rea-agents@6.4.0 --help$' "$TEST_LOG"
  fi
  : > "$TEST_LOG"
  "$repo/dot" init > "$sandbox/repeat.log" 2>&1
  ! grep -Eq '^curl |^pi install |^cua-driver skills install' "$TEST_LOG" || fail
  calls_before="$(wc -c < "$TEST_LOG")"
  "$repo/dot" diff > "$sandbox/diff.log"
  "$repo/dot" status > "$sandbox/status.log"
  [[ ! -s "$sandbox/diff.log" && ! -s "$sandbox/status.log" ]] || fail
  [[ "$(wc -c < "$TEST_LOG")" == "$calls_before" ]] || fail
  jq -e '.defaultProvider == "local" and .defaultModel == "chosen" and .localState == 42' "$HOME/.pi/agent/settings.json" >/dev/null
  [[ "$(cat "$HOME/.pi/agent/auth.json")" == keep ]] || fail
  grep -q 'name = Local Override' "$HOME/.gitconfig.local"
  [[ "$(git config --global --get user.email)" == existing@example.invalid ]] || fail
  [[ "$(git config --global --includes --get user.name)" == 'Local Override' ]] || fail
  for file in .pi/agent/mcp-auth.json .pi/agent/trust.json .agents/.skill-lock.json .feynman/auth.json .config/fish/fish_variables; do
    [[ "$(cat "$HOME/$file")" == 'local state' ]] || fail
  done
  "$repo/dot" doctor > "$sandbox/doctor.log" 2>&1
  if [[ "$selected" == work ]]; then
    for stage in brew mise cua-driver pi; do
      rm -f "$HOME/.pi/agent/npm/node_modules/pi-web-access/package.json"
      : > "$TEST_LOG"
      if FAIL_STAGE="$stage" "$repo/dot" init > "$sandbox/failure.log" 2>&1; then
        echo "Unexpected success after $stage failure" >&2; exit 1
      fi
      ! grep -q '^herdr ' "$TEST_LOG" || fail
      ! grep -q '^Done\.' "$sandbox/failure.log" || fail
    done
    mv "$HOME/.local/bin/cua-driver" "$sandbox/saved-cua"
    : > "$TEST_LOG"
    if FAIL_STAGE=curl "$repo/dot" init > "$sandbox/download.log" 2>&1; then
      echo 'Unexpected success after installer download failure' >&2; exit 1
    fi
    [[ ! -e "$HOME/.local/bin/cua-driver" ]] || fail
    ! grep -q '^herdr ' "$TEST_LOG" || fail
    mv "$sandbox/saved-cua" "$HOME/.local/bin/cua-driver"
    : > "$TEST_LOG"
    "$repo/dot" init --upgrade > "$sandbox/upgrade.log" 2>&1
    ! grep -q -- --no-upgrade "$TEST_LOG" || fail
    # Missing SDK content is restored by Cua, without changing its agent link.
    rm "$HOME/.cua-driver/skills/cua-driver/SKILL.md"
    : > "$TEST_LOG"
    "$repo/dot" init > "$sandbox/skill.log" 2>&1
    grep -q '^cua-driver skills install$' "$TEST_LOG"
    [[ -L "$HOME/.agents/skills/cua-driver" ]] || fail
    # A work migration never deletes local personal leftovers; doctor flags them.
    mkdir -p "$HOME/.agents/skills/reverse-engineer-anything"
    echo 'local personal skill' > "$HOME/.agents/skills/reverse-engineer-anything/SKILL.md"
    if "$repo/dot" doctor > "$sandbox/leftovers.log" 2>&1; then
      echo 'Doctor missed a personal leftover on work' >&2; exit 1
    fi
    grep -q 'Personal leftover' "$sandbox/leftovers.log"
    [[ -f "$HOME/.agents/skills/reverse-engineer-anything/SKILL.md" ]] || fail
    rm -r "$HOME/.agents/skills/reverse-engineer-anything"
  fi
  echo "$selected: configuration, full init, existing tools, repeated init, doctor passed"
done
# Legacy directory symlinks must not redirect writes into old repositories.
mv "$HOME/.config/nvim" "$sandbox/legacy-nvim"
echo 'legacy contents' > "$sandbox/legacy-nvim/README.md"
ln -s "$sandbox/legacy-nvim" "$HOME/.config/nvim"
if "$repo/dot" apply --force > "$sandbox/legacy.log" 2>&1; then
  echo 'Legacy directory symlink was not refused' >&2; exit 1
fi
[[ "$(cat "$sandbox/legacy-nvim/README.md")" == 'legacy contents' ]] || fail
grep -q 'symlink' "$sandbox/legacy.log"
rm "$HOME/.config/nvim"
mv "$sandbox/legacy-nvim" "$HOME/.config/nvim"
base="$("$repo/dot" package list base)"
all="$("$repo/dot" package list)"
grep -q '"ripgrep"' <<< "$base"
while IFS= read -r name; do
  ! grep -Fq "\"$name\"" <<< "$base" || fail
done < <(awk -F'"' '/^(brew|cask|mas) / {print $2}' "$repo/packages/Brewfile.personal")
! grep -Eq '"(microsoft-teams|microsoft-outlook|microsoft-word|microsoft-excel|zoom|google-chrome)"' <<< "$all" || fail
echo 'Smoke tests passed. No software installation or live-home deployment performed.'

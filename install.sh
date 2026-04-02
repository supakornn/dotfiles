#!/bin/bash
# =============================================================================
# install.sh — Bootstrap a new Mac from dotfiles
# Usage: ./install.sh
# =============================================================================

set -e

GITHUB_USERNAME="supakornn"
DOTFILES_REPO="dotfiles"

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}  →${NC} $1"; }
success() { echo -e "${GREEN}  ✓${NC} $1"; }
warn()    { echo -e "${YELLOW}  !${NC} $1"; }
error()   { echo -e "${RED}  ✗${NC} $1"; exit 1; }
header()  { echo -e "\n${BOLD}$1${NC}"; echo "  $(printf '─%.0s' {1..50})"; }

# =============================================================================
# Pre-flight
# =============================================================================
header "Pre-flight checks"

# macOS only
[[ "$(uname)" == "Darwin" ]] || error "This script is for macOS only."
success "macOS detected"

# Xcode command line tools
if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    # Wait for installation to complete
    until xcode-select -p &>/dev/null; do sleep 5; done
    success "Xcode Command Line Tools installed"
else
    success "Xcode Command Line Tools already installed"
fi

# =============================================================================
# Homebrew
# =============================================================================
header "Homebrew"

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for Apple Silicon
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "Homebrew installed"
else
    success "Homebrew already installed"
fi

info "Updating Homebrew..."
brew update --quiet
success "Homebrew up to date"

# =============================================================================
# chezmoi
# =============================================================================
header "chezmoi"

if ! command -v chezmoi &>/dev/null; then
    info "Installing chezmoi..."
    brew install chezmoi
    success "chezmoi installed"
else
    success "chezmoi already installed ($(chezmoi --version | head -1))"
fi

# =============================================================================
# Secrets
# =============================================================================
header "Secrets"

CHEZMOI_CONFIG="$HOME/.config/chezmoi/chezmoi.toml"

if [[ ! -f "$CHEZMOI_CONFIG" ]]; then
    echo ""
    echo -e "  ${YELLOW}Your WakaTime API key is needed for Zed settings.${NC}"
    echo -e "  Find it at: https://wakatime.com/settings/api-key"
    echo ""
    read -rp "  WakaTime API key (leave blank to skip): " WAKATIME_KEY
    echo ""

    mkdir -p "$(dirname "$CHEZMOI_CONFIG")"
    cat > "$CHEZMOI_CONFIG" <<EOF
[data]
    wakatimeApiKey = "${WAKATIME_KEY}"
EOF
    success "Created chezmoi config at $CHEZMOI_CONFIG"
else
    success "chezmoi config already exists"
fi

# =============================================================================
# Dotfiles
# =============================================================================
header "Dotfiles"

CHEZMOI_SOURCE="$HOME/.local/share/chezmoi"

if [[ ! -d "$CHEZMOI_SOURCE/.git" ]]; then
    info "Initializing dotfiles from GitHub..."
    chezmoi init --apply "github.com/$GITHUB_USERNAME/$DOTFILES_REPO"
    success "Dotfiles applied"
else
    info "Dotfiles repo already exists, applying..."
    chezmoi apply
    success "Dotfiles applied"
fi

# =============================================================================
# Packages
# =============================================================================
header "Homebrew packages (brew bundle)"

BREWFILE="$CHEZMOI_SOURCE/Brewfile"

if [[ -f "$BREWFILE" ]]; then
    info "Installing packages from Brewfile (this may take a while)..."
    brew bundle --file="$BREWFILE" --no-lock
    success "All packages installed"
else
    warn "Brewfile not found at $BREWFILE, skipping"
fi

# =============================================================================
# Fish shell
# =============================================================================
header "Fish shell"

FISH_PATH="$(command -v fish 2>/dev/null || echo /opt/homebrew/bin/fish)"

if [[ ! -f "$FISH_PATH" ]]; then
    error "Fish not found. Make sure brew bundle completed successfully."
fi

if ! grep -q "$FISH_PATH" /etc/shells; then
    info "Adding fish to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi

if [[ "$SHELL" != "$FISH_PATH" ]]; then
    info "Setting fish as default shell..."
    chsh -s "$FISH_PATH"
    success "Default shell set to fish (takes effect on next login)"
else
    success "Fish is already the default shell"
fi

# ---- Fisher + plugins ----
if ! fish -c "type -q fisher" 2>/dev/null; then
    info "Installing Fisher plugin manager..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    success "Fisher installed"
else
    success "Fisher already installed"
fi

FISH_PLUGINS_FILE="$HOME/.config/fish/fish_plugins"
if [[ -f "$FISH_PLUGINS_FILE" ]]; then
    info "Installing fish plugins..."
    fish -c "fisher update"
    success "Fish plugins installed"
fi

# =============================================================================
# Tmux Plugin Manager (TPM)
# =============================================================================
header "Tmux Plugin Manager"

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [[ ! -d "$TPM_DIR" ]]; then
    info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    success "TPM installed"
else
    success "TPM already installed"
fi

info "Installing tmux plugins..."
"$TPM_DIR/bin/install_plugins" 2>/dev/null || true
success "Tmux plugins installed"

# =============================================================================
# Rust (rustup)
# =============================================================================
header "Rust"

if ! command -v rustup &>/dev/null; then
    info "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env"
    success "Rust installed"
else
    success "Rust already installed ($(rustc --version))"
fi

# =============================================================================
# Spicetify
# =============================================================================
header "Spicetify"

if command -v spicetify &>/dev/null && [[ -d "/Applications/Spotify.app" ]]; then
    info "Applying Spicetify..."
    spicetify backup apply 2>/dev/null || spicetify apply 2>/dev/null || true
    success "Spicetify applied"
else
    warn "Spotify not found or spicetify not installed, skipping"
fi

# =============================================================================
# Done
# =============================================================================
echo ""
echo -e "${GREEN}${BOLD}  All done! 🎉${NC}"
echo ""
echo -e "  ${YELLOW}Next steps:${NC}"
echo -e "  • Restart your terminal (or run: exec fish)"
echo -e "  • In tmux, press ${BOLD}prefix + I${NC} to install plugins"
echo -e "  • Sign in to: Raycast, Bartender, Obsidian, etc."
echo ""

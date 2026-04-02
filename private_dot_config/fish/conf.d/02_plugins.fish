# ---- Starship prompt ----
starship init fish | source

# ---- Zoxide ----
zoxide init fish | source

# ---- FZF (optional if needed) ----
set -gx FZF_DEFAULT_COMMAND 'fd --type f'

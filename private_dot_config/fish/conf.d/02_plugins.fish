# ---- Starship prompt ----
starship init fish | source

# ---- Zoxide ----
zoxide init fish | source

# ---- FZF ----
set -gx FZF_DEFAULT_COMMAND 'fd --type f'
set -gx FZF_DEFAULT_OPTS "\
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
  --color=selected-bg:#313244 \
  --color=border:#b4befe,label:#cdd6f4"

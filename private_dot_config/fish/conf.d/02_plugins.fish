# ---- Starship prompt ----
starship init fish | source

# ---- Zoxide ----
zoxide init fish | source

# ---- FZF ----
set -gx FZF_DEFAULT_COMMAND 'fd --type f'
set -gx FZF_DEFAULT_OPTS "\
  --color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39 \
  --color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78 \
  --color=marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39 \
  --color=selected-bg:#ccd0da \
  --color=border:#7287fd,label:#4c4f69"

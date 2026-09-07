alias ll='eza --color=always --long --git --icons=always'
alias la='eza -la --color=always --long --git --icons=always'
alias ls='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --tree --level=2'
alias lg='lazygit --use-config-file="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/catppuccin-macchiato.yml"'

abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a reload 'source ~/.config/fish/config.fish'

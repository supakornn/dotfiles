alias ll='eza --color=always --long --git --icons=always'
alias la='eza -la --color=always --long --git --icons=always'
alias ls='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --tree --level=2'
function lg --wraps lazygit --description 'Lazygit with the catpuccin theme'
  lazygit --useconfig-file="$HOME/.config/lazygit/config.yaml,$HOME/.config/lazygit/catppuccin-macchiato.yaml" $argv
end

abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a reload 'source ~/.config/fish/config.fish'

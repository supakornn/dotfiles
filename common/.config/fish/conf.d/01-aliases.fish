alias ll='eza --color=always --long --git --icons=always'
alias la='eza -la --color=always --long --git --icons=always'
alias ls='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --tree --level=2'
function lg --wraps lazygit --description 'Lazygit with the Catppuccin theme'
  set -l flavor (command cat ~/.config/dotfiles/theme 2>/dev/null)
  test "$flavor" = latte; or set flavor macchiato
  lazygit --use-config-file="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/catppuccin-$flavor.yml" $argv
end

abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a reload 'source ~/.config/fish/config.fish'

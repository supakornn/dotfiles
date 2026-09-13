alias ll='eza --color=always --long --git --icons=always'
alias la='eza -la --color=always --long --git --icons=always'
alias ls='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --tree --level=2'
alias oc="opencode"
alias c="clear"


function lg --wraps lazygit --description 'Lazygit with the Catppuccin theme'
  set -l flavor (command cat ~/.config/dotfiles/theme 2>/dev/null)
  test "$flavor" = latte; or set flavor macchiato
  set -l config "$HOME/.config/lazygit/config.yml"
  set -l theme "$HOME/.config/lazygit/catppuccin-$flavor.yml"
  if test -f "$config" -a -f "$theme"
    lazygit --use-config-file="$config,$theme" $argv
  else
    lazygit $argv
  end
end

abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a reload 'source ~/.config/fish/config.fish'

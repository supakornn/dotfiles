function bat
    set -l flavor (command cat ~/.config/dotfiles/theme 2>/dev/null)
    test "$flavor" = latte; and set flavor Latte; or set flavor Macchiato
    command bat --theme="Catppuccin $flavor" --style=plain --paging=never $argv
end

if status is-interactive
    set -l color_theme dark
    if test "$(command cat ~/.config/dotfiles/theme 2>/dev/null)" = latte
        set color_theme light
    end
    fish_config theme choose catppuccin-macchiato --color-theme=$color_theme
end

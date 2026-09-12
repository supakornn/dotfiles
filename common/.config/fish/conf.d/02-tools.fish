if test -f "$HOME/.cache/dotfiles/starship.toml"
    set -gx STARSHIP_CONFIG "$HOME/.cache/dotfiles/starship.toml"
end

if type -q starship
    starship init fish | source
end

if type -q zoxide
    zoxide init fish | source
end

if type -q fzf
    set -gx FZF_DEFAULT_COMMAND 'fd --type f'
    if test (command cat "$HOME/.config/dotfiles/theme" 2>/dev/null) = latte
        set -gx FZF_DEFAULT_OPTS '--color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39 --color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78 --color=marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39 --color=selected-bg:#ccd0da --color=border:#7287fd,label:#4c4f69'
    else
        set -gx FZF_DEFAULT_OPTS '--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 --color=selected-bg:#363a4f --color=border:#b7bdf8,label:#cad3f5'
    end
end

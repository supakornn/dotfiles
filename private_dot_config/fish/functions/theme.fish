function theme --description "Switch between catppuccin dark (macchiato/mocha/frappe) and latte (light)"
    set chezmoi_config ~/.config/chezmoi/chezmoi.toml

    set current (string match -r 'catppuccin_flavor = "(\w+)"' (cat $chezmoi_config) | tail -1)

    switch $argv[1]
        case dark macchiato mocha frappe ''
            if test "$argv[1]" = ""
                if test "$current" = "latte"
                    set flavor macchiato
                else
                    set flavor latte
                end
            else if test "$argv[1]" = "dark"
                set flavor macchiato
            else
                set flavor $argv[1]
            end
        case light latte
            set flavor latte
        case '*'
            echo "Usage: theme [dark|light|macchiato|mocha|frappe|latte]"
            echo "Current: catppuccin $current"
            return 1
    end

    sed -i '' "s/catppuccin_flavor = \".*\"/catppuccin_flavor = \"$flavor\"/" $chezmoi_config
    chezmoi apply
    source ~/.config/fish/config.fish
    for f in ~/.config/fish/conf.d/*.fish
        source $f
    end

    if command -q tmux; and test -n "$TMUX"
        tmux source-file ~/.tmux.conf
    end

    echo "Switched to catppuccin $flavor"
end

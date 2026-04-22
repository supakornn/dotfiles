function theme --description "Switch between catppuccin mocha (dark) and latte (light)"
    set chezmoi_config ~/.config/chezmoi/chezmoi.toml

    set current (string match -r 'catppuccin_flavor = "(\w+)"' (cat $chezmoi_config) | tail -1)

    switch $argv[1]
        case dark mocha ''
            if test "$argv[1]" = ""
                if test "$current" = "mocha"
                    set flavor latte
                else
                    set flavor mocha
                end
            else
                set flavor mocha
            end
        case light latte
            set flavor latte
        case '*'
            echo "Usage: theme [dark|light|mocha|latte]"
            echo "Current: catppuccin $current"
            return 1
    end

    sed -i '' "s/catppuccin_flavor = \".*\"/catppuccin_flavor = \"$flavor\"/" $chezmoi_config
    chezmoi apply
    source ~/.config/fish/config.fish

    echo "Switched to catppuccin $flavor"
end

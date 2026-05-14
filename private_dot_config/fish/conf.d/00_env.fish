# ---- PATHs ----
set -gx PATH $HOME/bin $PATH
set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH /usr/local/bin $PATH

# sdkman (Fish doesn't support Bash-style init scripts directly)
set -gx SDKMAN_DIR $HOME/.sdkman
if test -f "$SDKMAN_DIR/bin/sdkman-init.sh"
    bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh && env" | grep '^SDKMAN_' | while read -l line
        set -gx (string split '=' -- $line)[1] (string split '=' -- $line)[2]
    end
end

# ---- Homebrew ----
eval (/opt/homebrew/bin/brew shellenv)

# ---- GPG ----
set -gx GPG_TTY (tty)

# ---- Spicetify ----
set -gx PATH $PATH $HOME/.spicetify

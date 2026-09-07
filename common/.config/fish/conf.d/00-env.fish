# Homebrew supports both Apple Silicon and Intel Macs.
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -x /usr/local/bin/brew
    eval (/usr/local/bin/brew shellenv)
end

fish_add_path $HOME/bin $HOME/.local/bin
set -gx GPG_TTY (tty)
set -gx GHQ_ROOT $HOME/Documents/src

function dco
    $argv | docker-color-output
end
abbr -a dco dco

function repo
    set selected (ghq list | fzf --preview "ls (ghq root)/{}" --height 40%)
    test -n "$selected" && cd (ghq root)/$selected
end

abbr -a get ghq get

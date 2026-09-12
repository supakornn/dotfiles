local state = vim.fn.expand("~/.config/dotfiles/theme")
local flavor = vim.fn.filereadable(state) == 1 and vim.fn.readfile(state)[1] or "macchiato"

return {
	flavor = flavor == "latte" and "latte" or "macchiato",
}

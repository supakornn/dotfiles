return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "auto",
			background = {
				light = "latte",
				dark = "macchiato",
			},
			transparent_background = false,
			integrations = {
				blink_cmp = true,
				gitsigns = true,
				lazy = true,
				mason = true,
				mini = { enabled = true },
				neotree = true,
				noice = true,
				notify = true,
				telescope = { enabled = true },
				treesitter = true,
				which_key = true,
			},
		},
	},
}

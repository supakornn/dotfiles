return {
	{
		"catppuccin/nvim",
		lazy = false,
		priority = 1000,
		config = function()
			local theme = require("supakornn.theme")
			require("catppuccin").setup({
				flavour = theme.flavor,
				transparent_background = true,
				float = { transparent = true, solid = false },
				integrations = {
					diffview = true,
					fidget = true,
					harpoon = true,
					mason = true,
					native_lsp = { enabled = true },
					noice = true,
					notify = true,
					symbols_outline = true,
					snacks = {
						enabled = true,
						indent_scope_color = "mauve",
					},
					render_markdown = true,
					telescope = true,
					treesitter = true,
					treesitter_context = true,
					ufo = true,
					which_key = true,
				},
			})
			local palette = require("catppuccin.palettes").get_palette(theme.flavor)
			vim.cmd.colorscheme("catppuccin-" .. theme.flavor)

			-- Keep Telescope transparent while preserving its palette accents.
			vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = palette.blue, bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = palette.blue, bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = palette.blue, bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = palette.blue, bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopeTitle", { fg = palette.mauve, bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = palette.mauve, bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = palette.mauve, bg = "none" })
			vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = palette.mauve, bg = "none" })

			-- Hide all semantic highlights until upstream issues are resolved (https://github.com/catppuccin/nvim/issues/480)
			for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
				vim.api.nvim_set_hl(0, group, {})
			end
		end,
	},
}

-- rosewater = "#f5e0dc",
-- flamingo = "#f2cdcd",
-- pink = "#f5c2e7",
-- mauve = "#cba6f7",
-- red = "#f38ba8",
-- maroon = "#eba0ac",
-- peach = "#fab387",
-- yellow = "#f9e2af",
-- green = "#a6e3a1",
-- teal = "#94e2d5",
-- sky = "#89dceb",
-- sapphire = "#74c7ec",
-- blue = "#89b4fa",
-- lavender = "#b4befe",
-- text = "#cdd6f4",
-- subtext1 = "#bac2de",
-- subtext0 = "#a6adc8",
-- overlay2 = "#9399b2",
-- overlay1 = "#7f849c",
-- overlay0 = "#6c7086",
-- surface2 = "#585b70",
-- surface1 = "#45475a",
-- surface0 = "#313244",
-- base = "#1e1e2e",
-- mantle = "#181825",
-- crust = "#11111b",

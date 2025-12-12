return {
	"ellisonleao/gruvbox.nvim",
	--	lazy = true, -- Load only when needed
	priority = 1000, -- To ensure it loads before plugins that might depend on colorschemes
	config = function()
		require("gruvbox").setup({
			undercurl = true,
			underline = true,
			bold = true,
			italic = {
				strings = true,
				emphasis = true,
				comments = true,
				operators = false,
				folds = true,
			},
			strikethrough = true,
			invert_selection = false,
			invert_signs = false,
			invert_tabline = false,
			invert_intend_guides = false,
			inverse = true, -- invert background for search, diffs, statuslines, etc
			contrast = "hard", -- can be "soft" or "hard"
			palette_overrides = {},
			overrides = {},
			dim_inactive = false,
			transparent_mode = false,
		})
	end,
}

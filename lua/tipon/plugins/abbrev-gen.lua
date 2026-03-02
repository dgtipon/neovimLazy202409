return {
	dir = "~/Documents/Projects/abbrev-gen.nvim",
	dev = true, -- Enables dev mode and Lazy treats as local and skips git checks
	ft = "markdown",
	dependencies = { "hrsh7th/nvim-cmp" },
	config = function()
		require("abbrev-gen").setup({
			enable_keymaps = true,
			enable_escape = true,
			register_cmp_source = true, -- Enables the CMP source automatically
		})
	end,
}

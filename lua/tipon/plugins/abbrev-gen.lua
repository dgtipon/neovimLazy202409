return {
	"dgtipon/abbrev-gen.nvim",
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

return {
	"rmagatti/auto-session",
	config = function()
		local auto_session = require("auto-session")

		auto_session.setup({
			auto_restore_enabled = false,
			auto_session_suppress_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
		})

		local keymap = vim.keymap

		keymap.set("n", "<leader>sr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
		keymap.set("n", "<leader>ss", "<cmd>SessionSave<CR>", { desc = "Save session for cwd" }) -- save workspace session for current working directory
		keymap.set("n", "<leader>sf", "<cmd>SessionSearch<CR>", { desc = "Search for session" }) -- save workspace session for current working directory
	end,
}

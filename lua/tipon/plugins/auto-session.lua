return {
	"rmagatti/auto-session",
	config = function()
		local auto_session = require("auto-session")

		auto_session.setup({
			auto_save = false,
			auto_restore_enabled = false,
			auto_session_suppress_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
		})

		local keymap = vim.keymap

		keymap.set("n", "<leader>sr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" })
		keymap.set("n", "<leader>ss", "<cmd>SessionSave<CR>", { desc = "Save session for cwd" })
		keymap.set("n", "<leader>sf", "<cmd>SessionSearch<CR>", { desc = "Search for session" })
		keymap.set("n", "<leader>sd", "<cmd>SessionDelete<CR>", { desc = "Delete current session" })
	end,
}

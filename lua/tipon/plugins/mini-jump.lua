return {
	"echasnovski/mini.nvim",
	branch = "stable", -- Use stable for reliability
	config = function()
		require("mini.jump").setup({
			-- Module mappings. Use `''` (empty string) to disable one.
			mappings = {
				forward = "f",
				backward = "F",
				forward_till = "t",
				backward_till = "T",
				repeat_jump = ";",
			},
			-- Delay values (in ms) for different functionalities. Set any to -1 to disable.
			delay = {
				-- Delay between jump and highlighting all possible jumps
				highlight = 250,
				-- Delay between jump and automatic stop if idle (no jump is done)
				idle_stop = 10000000, -- Disable idle stop by default (set to 1500 for clever-f-like timeout)
			},
		})
	end,
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ import = "tipon.plugins" },
	{ import = "tipon.plugins.lsp" },
	{ import = "tipon.colorschemes" },
	-- For unit testing
	{ "nvim-lua/plenary.nvim" }, -- For tests
	checker = { enabled = false }, -- Disable auto-check/sync
	change_detection = { notify = false },
	performance = { -- Optimize for faster startup
		rtp = { reset = false },
	},
})

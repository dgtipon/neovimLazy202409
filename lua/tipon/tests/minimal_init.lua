-- ~/.config/nvim/lua/tipon/tests/minimal_init.lua
-- Prepend Lazy to runtimepath if not already there
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load your core setup without colorscheme
require("tipon.core.options")
require("tipon.core.keymaps")

-- Load Lazy with your plugins (gruvbox included but not activated)
require("lazy").setup({
	{ import = "tipon.plugins" },
	{ import = "tipon.plugins.lsp" },
	{ import = "tipon.colorschemes" },
	{ "nvim-lua/plenary.nvim" }, -- For tests
	checker = { enabled = true, notify = false },
	change_detection = { notify = false },
})

-- No vim.cmd.colorscheme("gruvbox") here to avoid errors

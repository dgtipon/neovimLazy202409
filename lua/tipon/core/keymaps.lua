-- set leader key to space
vim.g.mapleader = ";"
vim.g.maplocalleader = ","

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- Map a key to show native key bindings
keymap.set("n", "<leader><Space>", ":WhichKey<CR>", { desc = "WhichKey", silent = true })

-- clear search highlights
keymap.set("n", "<leader>o", ":nohl<CR>", { desc = "Highlights Off" })

-- toggle window maximize/minimize of a split
keymap.set("n", "<C-w>m", ":MaximizerToggle<CR>", { desc = "Max/min toggle of split" })

-- vertical split, file directory to pwd, terminal, input
keymap.set(
	"n",
	"<C-w>S",
	":split<CR>:cd %:p:h<CR>:terminal<CR>:startinsert<CR>",
	{ silent = true, desc = "Open terminal in h split" }
)

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- Tabs
keymap.set("n", "go", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- Open new tab

-- change directory
keymap.set("n", "<leader>n", "<cmd>cd .config/nvim<CR>", { desc = ".config/nvim" })
keymap.set("n", "<leader>w", ":cd %:p:h<CR>", { desc = "Current file > pwd" })

keymap.set("n", "<leader>tt", ":PlenaryBustedFile %<CR>", { desc = "Run tests for current file" })

-- ColorSchemes

-- Background
keymap.set("n", "<leader>cd", "<cmd>set background=dark<CR>", { desc = "Dark background" })
keymap.set("n", "<leader>cl", "<cmd>set background=light<CR>", { desc = "Light background" })

-- tokyonight
keymap.set("n", "<leader>ctd", "<cmd>colorscheme tokyonight-day<CR>", { desc = "Tokyonight-day" })
keymap.set("n", "<leader>ctm", "<cmd>colorscheme tokyonight-moon<CR>", { desc = "Tokyonight-moon" })
keymap.set("n", "<leader>ctn", "<cmd>colorscheme tokyonight-night<CR>", { desc = "Tokyonight-night" })
keymap.set("n", "<leader>cts", "<cmd>colorscheme tokyonight-storm<CR>", { desc = "Tokyonight-storm" })

-- kanagawa
keymap.set("n", "<leader>ckd", "<cmd>colorscheme kanagawa-dragon<CR>", { desc = "Kanagawa-dragon" })
keymap.set("n", "<leader>ckl", "<cmd>colorscheme kanagawa-lotus<CR>", { desc = "Kanagawa-lotus" })
keymap.set("n", "<leader>ckw", "<cmd>colorscheme kanagawa-wave<CR>", { desc = "Kanagawa-wave" })

-- gruvbox
keymap.set("n", "<leader>cg", "<cmd>colorscheme gruvbox<CR>", { desc = "Gruvbox" })

-- bamboo
keymap.set("n", "<leader>cb", "<cmd>colorscheme bamboo<CR>", { desc = "Bamboo" })

-- catppuccin
keymap.set("n", "<leader>ccl", "<cmd>colorscheme catppuccin-latte<CR>", { desc = "Catppuccin-latte" })
keymap.set("n", "<leader>ccf", "<cmd>colorscheme catppuccin-frappe<CR>", { desc = "Catppuccin-frappe" })
keymap.set("n", "<leader>ccm", "<cmd>colorscheme catppuccin-macchiato<CR>", { desc = "Catppuccin-macchiato" })
keymap.set("n", "<leader>cco", "<cmd>colorscheme catppuccin-mocha<CR>", { desc = "Catppuccin-mocha" })

-- nightfox
keymap.set("n", "<leader>cnc", "<cmd>colorscheme carbonfox<CR>", { desc = "Carbonfox" })
keymap.set("n", "<leader>cnw", "<cmd>colorscheme dawnfox<CR>", { desc = "Dawnfox" })
keymap.set("n", "<leader>cny", "<cmd>colorscheme dayfox<CR>", { desc = "Dayfox" })
keymap.set("n", "<leader>cnk", "<cmd>colorscheme duskfox<CR>", { desc = "Duskfox" })
keymap.set("n", "<leader>cnn", "<cmd>colorscheme nordfox<CR>", { desc = "Nordfox" })
keymap.set("n", "<leader>cnn", "<cmd>colorscheme nightfox<CR>", { desc = "Nightfox" })
keymap.set("n", "<leader>cnt", "<cmd>colorscheme terafox<CR>", { desc = "Terafox" })

-- everforest
keymap.set("n", "<leader>ce", "<cmd>colorscheme everforest<CR>", { desc = "Everforest" })

-- dracula
keymap.set("n", "<leader>cD", "<cmd>colorscheme dracula<CR>", { desc = "Dracula" })

keymap.set("n", "<leader>a", function()
	if vim.bo.filetype == "markdown" then
		local abbrev_gen = require("tipon.core.abbrev-gen")
		local word = vim.fn.expand("<cword>"):lower()
		local result = abbrev_gen.try_reverse(word)
		if result then
			vim.notify("Abbrev breakdown: " .. result, vim.log.levels.INFO) -- Or use a popup
		else
			vim.notify("No abbrev found", vim.log.levels.WARN)
		end
	else
		vim.notify("Abbreviations available only in Markdown buffers", vim.log.levels.WARN)
	end
end, { desc = "Show abbrev breakdown for word" })

keymap.set("n", "<leader>1", function()
	if vim.bo.filetype == "markdown" then
		require("tipon.core.abbrev-gen").list_one_letter_abbrevs()
	else
		vim.notify("One-letter abbrev list available only in Markdown buffers", vim.log.levels.WARN)
	end
end, { desc = "Show all One-letter root abbrevs" })

keymap.set("n", "<leader>2", function()
	if vim.bo.filetype == "markdown" then
		require("tipon.core.abbrev-gen").list_two_letter_abbrevs()
	else
		vim.notify("Two-letter abbrev list available only in Markdown buffers", vim.log.levels.WARN)
	end
end, { desc = "Show all two-letter root abbrevs" })

keymap.set("n", "<leader>p", function()
	if vim.bo.filetype == "markdown" then
		require("tipon.core.abbrev-gen").list_prefixes()
	else
		vim.notify("Prefix abbrev list available only in Markdown buffers", vim.log.levels.WARN)
	end
end, { desc = "Show all prefix abbrevs" })

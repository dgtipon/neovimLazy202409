-- set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = ","

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- Map a key to show native key bindings
keymap.set("n", "<leader><Space>", ":WhichKey<CR>", { desc = "WhichKey", silent = true })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
-- keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- ColorSchemes

-- Background
keymap.set("n", "<leader>kd", "<cmd>set background=dark<CR>", { desc = "Dark background" })
keymap.set("n", "<leader>kl", "<cmd>set background=light<CR>", { desc = "Light background" })

-- tokyonight
keymap.set("n", "<leader>ktd", "<cmd>colorscheme tokyonight-day<CR>", { desc = "Tokyonight-day" })
keymap.set("n", "<leader>ktm", "<cmd>colorscheme tokyonight-moon<CR>", { desc = "Tokyonight-moon" })
keymap.set("n", "<leader>ktn", "<cmd>colorscheme tokyonight-night<CR>", { desc = "Tokyonight-night" })
keymap.set("n", "<leader>kts", "<cmd>colorscheme tokyonight-storm<CR>", { desc = "Tokyonight-storm" })

-- kanagawa
keymap.set("n", "<leader>kkd", "<cmd>colorscheme kanagawa-dragon<CR>", { desc = "Kanagawa-dragon" })
keymap.set("n", "<leader>kkl", "<cmd>colorscheme kanagawa-lotus<CR>", { desc = "Kanagawa-lotus" })
keymap.set("n", "<leader>kkw", "<cmd>colorscheme kanagawa-wave<CR>", { desc = "Kanagawa-wave" })

-- gruvbox
keymap.set("n", "<leader>kg", "<cmd>colorscheme gruvbox<CR>", { desc = "Gruvbox" })

-- bamboo
keymap.set("n", "<leader>kb", "<cmd>colorscheme bamboo<CR>", { desc = "Bamboo" })

-- catppuccin
keymap.set("n", "<leader>kcl", "<cmd>colorscheme catppuccin-latte<CR>", { desc = "Catppuccin-latte" })
keymap.set("n", "<leader>kcf", "<cmd>colorscheme catppuccin-frappe<CR>", { desc = "Catppuccin-frappe" })
keymap.set("n", "<leader>kcm", "<cmd>colorscheme catppuccin-macchiato<CR>", { desc = "Catppuccin-macchiato" })
keymap.set("n", "<leader>kco", "<cmd>colorscheme catppuccin-mocha<CR>", { desc = "Catppuccin-mocha" })

-- nightfox
keymap.set("n", "<leader>knc", "<cmd>colorscheme carbonfox<CR>", { desc = "Carbonfox" })
keymap.set("n", "<leader>knw", "<cmd>colorscheme dawnfox<CR>", { desc = "Dawnfox" })
keymap.set("n", "<leader>kny", "<cmd>colorscheme dayfox<CR>", { desc = "Dayfox" })
keymap.set("n", "<leader>knk", "<cmd>colorscheme duskfox<CR>", { desc = "Duskfox" })
keymap.set("n", "<leader>knn", "<cmd>colorscheme nordfox<CR>", { desc = "Nordfox" })
keymap.set("n", "<leader>knn", "<cmd>colorscheme nightfox<CR>", { desc = "Nightfox" })
keymap.set("n", "<leader>knt", "<cmd>colorscheme terafox<CR>", { desc = "Terafox" })

-- everforest
keymap.set("n", "<leader>ke", "<cmd>colorscheme everforest<CR>", { desc = "Everforest" })

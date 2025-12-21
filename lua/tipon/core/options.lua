-- netrw set to tree style
vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt -- for conciseness

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance

-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- add english dictionary and suggestion files to rtp
opt.runtimepath:append("/usr/share/vim/vimfiles")

-- persistent undo across sessions
opt.undofile = true

-- Markdown-specific date/time insertions
local function insert_with_datetime(text)
	local dt = vim.fn.strftime("%Y-%m-%d %H:%M:%S") -- Customize format if needed
	local full_text = text .. dt
	-- Insert at cursor
	vim.api.nvim_put({ full_text }, "c", true, true)
	-- Exit insert mode
	vim.cmd("stopinsert")
end

-- Enable spell checking for Markdown files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us" -- Change to "en_gb" for British English if preferred
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.background = "light"

		local bufnr = vim.api.nvim_get_current_buf()
		local keymap = vim.keymap

		keymap.set("i", "<A-p>", function()
			insert_with_datetime("Posted on X: ")
		end, {
			buffer = bufnr,
			desc = "Insert 'Posted on X: ' + date/time and exit insert mode",
		})

		keymap.set("i", "<A-t>", function()
			insert_with_datetime("Timestamp: ")
		end, {
			buffer = bufnr,
			desc = "Insert 'Timestamp: ' + date/time and exit insert mode",
		})

		require("which-key").add({
			{ "<A-p>", desc = "Insert Note with date/time", mode = "i", buffer = bufnr },
			{ "<A-t>", desc = "Insert Timestamp with date/time", mode = "i", buffer = bufnr },
		})

		-- Normal-mode key to show all insert-mode mappings via which-key
		keymap.set("n", "<leader>?i", function()
			require("which-key").show({ keys = "", mode = "i" })
		end, {
			buffer = bufnr,
			desc = "Show insert-mode keys",
			silent = true,
		})

		-- Optional: Register this new key with which-key for visibility in the main popup
		require("which-key").add({
			{ "<leader>?i", desc = "Show insert-mode keys", mode = "n", buffer = bufnr },
		})
	end,
})

-- Autocmd for filetype-specific colorscheme (added for Markdown bamboo)
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*", -- Applies to all buffers
	callback = function()
		local scheme = (vim.bo.filetype == "markdown") and "bamboo" or "gruvbox"
		local ok = pcall(vim.cmd.colorscheme, scheme)
		if not ok then
			vim.notify("Colorscheme " .. scheme .. " not found; using fallback", vim.log.levels.WARN)
			vim.cmd.colorscheme("habamax") -- Built-in fallback to avoid errors during early boot
		end
	end,
	desc = "Set colorscheme based on filetype (bamboo for markdown)",
})

-- Auto-save on InsertLeave for Markdown buffers (only if modified)
vim.api.nvim_create_autocmd("InsertLeave", {
	group = vim.api.nvim_create_augroup("MarkdownAutoSave", { clear = true }),
	callback = function()
		if vim.bo.filetype == "markdown" and vim.fn.bufname() ~= "" then -- Ensure it's Markdown and the buffer has a name
			vim.cmd("silent update")
		end
	end,
	desc = "Auto-save Markdown files on leaving insert mode",
})

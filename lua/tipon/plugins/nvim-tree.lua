return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local nvimtree = require("nvim-tree")

		-- recommended settings from nvim-tree documentation
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		nvimtree.setup({
			view = {
				width = 35,
				relativenumber = true,
			},
			-- change folder arrow icons
			renderer = {
				indent_markers = {
					enable = true,
				},
				icons = {
					glyphs = {
						folder = {
							arrow_closed = "", -- arrow when folder is closed
							arrow_open = "", -- arrow when folder is open
						},
					},
				},
			},
			-- disable window_picker for
			-- explorer to work well with
			-- window splits
			actions = {
				open_file = {

					window_picker = {
						enable = false,
					},
				},
			},
			filters = {
				custom = { ".DS_Store" },
			},
			git = {
				ignore = false,
			},
			on_attach = function(bufnr)
				local api = require("nvim-tree.api")
				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- Custom mappings
				vim.keymap.set("n", "<C-h>", api.node.open.horizontal, opts("Open: Horizontal Split"))
				-- Combined mapping for focusing nvim-tree and opening in horizontal split
				vim.keymap.set("n", "<A-h>", function()
					-- First, ensure nvim-tree is focused
					api.tree.focus()
					-- Save current window as nvimtree
					local cur_win = vim.api.nvim_get_current_win()
					-- Get current node from nvim-tree
					local node = api.tree.get_node_under_cursor()
					-- Open the selected node in a horizontal split
					api.node.open.horizontal(node)
					-- Focus back to the original window (nvim-tree)
					vim.api.nvim_set_current_win(cur_win)
				end, opts("Horizontal Split, focus to Explorer"))
				vim.keymap.set("n", "<A-v>", function()
					-- First, ensure nvim-tree is focused
					api.tree.focus()
					-- Save current window as nvimtree
					local cur_win = vim.api.nvim_get_current_win()
					-- Get current node from nvim-tree
					local node = api.tree.get_node_under_cursor()
					-- Open the selected node in a vertical split
					api.node.open.vertical(node)
					-- Focus back to the original window (nvim-tree)
					vim.api.nvim_set_current_win(cur_win)
				end, opts("Vertical Split, focus to Explorer"))

				-- Add other mappings as needed

				-- Default mappings, if you want them
				api.config.mappings.default_on_attach(bufnr)
			end,
		})

		-- set keymaps
		local keymap = vim.keymap -- for conciseness
		local api = require("nvim-tree.api")

		keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
		keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
		keymap.set(
			"n",
			"<leader>et",
			"<cmd>NvimTreeFindFileToggle<CR>",
			{ desc = "Toggle file explorer on current file" }
		) -- toggle file explorer on current file
		keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
		keymap.set("n", "<leader>ef", function()
			-- Close nvim-tree if it's open
			if api.tree.is_visible() then
				api.tree.close()
			end
			-- Get the directory of the current file
			local current_file_dir = vim.fn.expand("%:p:h")
			-- Change the current working directory to the directory of the current file
			vim.cmd("cd " .. current_file_dir)
			-- Change the root of nvimtree
			api.tree.change_root(current_file_dir)
			api.tree.toggle()
		end, { desc = "Explorer focus in dir of file" })
		keymap.set("n", "<leader>en", function()
			-- Make sure nvimtree has been opend and initialized
			api.tree.toggle()
			-- Close nvim-tree if it's open
			if api.tree.is_visible() then
				api.tree.close()
			end
			-- Change the root of nvim-tree to the specified directory
			-- Note: We use vim.fn.expand to expand the home directory
			local new_root = vim.fn.expand("~/.config/nvim/lua")
			api.tree.change_root(new_root)
			-- Toggle nvim-tree to open it again
			api.tree.toggle()
			api.tree.expand_all()
		end, { desc = "Explorer focus in dir of nvim" })
	end,
}

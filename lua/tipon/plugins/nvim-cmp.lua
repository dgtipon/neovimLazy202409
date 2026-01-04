return {
	"hrsh7th/nvim-cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-path", -- source for file system paths
		{
			"L3MON4D3/LuaSnip",
			-- follow latest release.
			version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
			-- install jsregexp (optional!).
			build = "make install_jsregexp",
		},
		"saadparwaiz1/cmp_luasnip", -- for autocompletion
		"rafamadriz/friendly-snippets", -- useful snippets
		"onsails/lspkind.nvim", -- vs-code like pictograms
	},
	config = function()
		local cmp = require("cmp")

		local luasnip = require("luasnip")

		local lspkind = require("lspkind")

		-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			completion = {
				autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
				completeopt = "menu,menuone,preview,noselect",
			},
			snippet = { -- configure how nvim-cmp interacts with snippet engine
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
				["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
				["<C-e>"] = cmp.mapping.abort(), -- close completion window
				["<CR>"] = cmp.mapping.confirm({ select = false }),
			}),
			-- sources for autocompletion (global)
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- snippets
				{ name = "buffer" }, -- text within current buffer
				{ name = "path" }, -- file system paths
			}),

			formatting = {
				fields = { "kind", "abbr", "menu" }, -- Ensure 'menu' is included for the right-side display
				format = function(entry, vim_item)
					-- Handle kind icons with lspkind (icons only, not text kind)
					local lspkind = require("lspkind")
					vim_item = lspkind.cmp_format({ with_text = false })(entry, vim_item) -- Icons only, no text kind

					-- Set menu to detail if available (this shows your abbrevs)
					local detail = entry:get_completion_item().detail
					if detail then
						vim_item.menu = " " .. detail -- Prepend space for spacing
					else
						vim_item.menu = " [" .. (entry.source.name or "Other") .. "]" -- Fallback to source name
					end

					return vim_item
				end,
			},
		})

		-- Markdown-specific sources (includes globals with tweaks + custom)
		cmp.setup.filetype("markdown", {
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{
					name = "luasnip", -- Snippets with higher threshold to reduce noise
					keyword_length = 3, -- Only trigger after 3+ chars
				},
				{ name = "buffer" },
				{ name = "path" },
				{
					name = "abbrev_pop",
					priority = 1000, -- Highest priority for your custom source
					keyword_length = 2, -- Trigger after 2 chars as before
				},
			}),
		})
		-- Register the custom source (update path to core)
		cmp.register_source("abbrev_pop", require("tipon.core.abbrev_cmp_source").new())
	end,
}

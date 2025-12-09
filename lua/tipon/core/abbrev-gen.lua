-- Abbrev-gen: Abbreviation expansion for Markdown using explicit JSON mappings

vim.notify("Abbrev-gen version 2.0 loaded (JSON-based expansions)", vim.log.levels.INFO)

local M = {} -- Module table

-- Path to your JSON file (adjust if placed elsewhere)
local json_path = vim.fn.stdpath("config") .. "/abolish_data.json" -- Adjust path

-- Single shared table for lookups (used by try_expand and future completion)
M.abbrevs = {}

-- Load and parse JSON once on plugin init (expanded abbrev -> word)
local function load_json_data()
	local json_path = vim.fn.stdpath("config") .. "/abolish_data.json" -- Adjust if needed
	local lines = vim.fn.readfile(json_path)
	if #lines == 0 then
		vim.notify("abolish_data.json not found or empty", vim.log.levels.ERROR)
		return {}
	end
	local json_str = table.concat(lines, "\n")
	local data = vim.fn.json_decode(json_str)

	-- Clear existing for reloads
	M.abbrevs = {}

	for _, entry in ipairs(data) do
		local root_abbrev = entry.root_abbrev:lower() -- Ensure consistency
		local root_word = entry.root_word
		local suffix_abbrevs = entry.suffix_abbrevs or {}
		local suffix_words = entry.suffix_words or {}
		for i, s_abbrev in ipairs(suffix_abbrevs) do
			local full_abbrev = root_abbrev .. s_abbrev:lower()
			local s_word = suffix_words[i] or "" -- Fallback
			local full_word = root_word .. s_word
			M.abbrevs[full_abbrev] = full_word
		end
	end
	vim.notify("Loaded " .. vim.tbl_count(M.abbrevs) .. " abbrev-word pairs from JSON", vim.log.levels.INFO)
end

-- Call on load
load_json_data()

-- Optional: User command to reload if JSON changes
vim.api.nvim_create_user_command("ReloadAbbrevJson", load_json_data, { desc = "Reload abbrev data from JSON" })

-- Expansion logic: Lookup in table, handle capitalization
-- No dictionary checks or dynamic generation
local function try_expand(abbrev)
	local is_capitalized = abbrev:sub(1, 1):match("%u") ~= nil
	local lower_abbrev = abbrev:lower()
	local expanded = M.abbrevs[lower_abbrev]
	if not expanded then
		return nil
	end
	if is_capitalized then
		expanded = expanded:sub(1, 1):upper() .. expanded:sub(2)
	end
	return expanded
end

-- Setup buffer-local mapping for Markdown files
local function setup_markdown_keymaps()
	vim.notify("Keymaps set for Markdown buffer", vim.log.levels.INFO)
	local triggers = { " ", ",", ";", ":", ".", "!", "?", "<" }
	for _, trigger in ipairs(triggers) do
		vim.keymap.set("i", trigger, function()
			return M.expand_abbrev(trigger)
		end, { expr = true, buffer = true, silent = true })
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = setup_markdown_keymaps,
})

-- If current buffer is markdown, setup immediately
if vim.bo.filetype == "markdown" then
	setup_markdown_keymaps()
end

-- Expansion handler (async to avoid textlock issues)
M.expand_abbrev = function(trigger_char)
	trigger_char = trigger_char or " "
	local pos = vim.api.nvim_win_get_cursor(0)
	local line = vim.api.nvim_get_current_line()
	local col = pos[2]
	local word_before = line:sub(1, col):match("%w+$")

	if not word_before then
		return trigger_char
	end

	local expanded = try_expand(word_before)
	if not expanded then
		return trigger_char
	end

	vim.schedule(function()
		local start_col = col - #word_before + 1
		local new_line = line:sub(1, start_col - 1) .. expanded .. line:sub(col + 1)
		vim.api.nvim_set_current_line(new_line)
		vim.api.nvim_win_set_cursor(0, { pos[1], start_col + #expanded - 1 })
		vim.api.nvim_feedkeys(trigger_char, "n", true)
	end)

	return ""
end

return M

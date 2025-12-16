-- Abbrev-gen: Abbreviation expansion for Markdown using explicit JSON mappings

-- vim.notify("Abbrev-gen version 2.0 loaded (JSON-based expansions)", vim.log.levels.INFO)

local M = {} -- Module table

-- Single shared table for lookups (used by try_expand and future completion)
M.abbrevs = {}
M.roots = {}

-- Load and parse JSON once on plugin init (expanded abbrev -> word)
local function load_json_data()
	local json_path = vim.fn.stdpath("config") .. "/abolish_obj_data.json" -- Adjust if needed
	local lines = vim.fn.readfile(json_path)
	if #lines == 0 then
		vim.notify("abolish_data.json not found or empty", vim.log.levels.ERROR)
		return {}
	end
	local json_str = table.concat(lines, "\n")
	local data = vim.fn.json_decode(json_str)
	M.json_data = data -- Export raw JSON for suffix lookups in completion

	-- Reverse expansion: Simple lookup on M.roots (base words only, no prefixes/suffixes)
	M.try_reverse = function(word)
		if #word < 2 then
			return nil
		end
		word = word:lower() -- Normalize for case-insensitive match

		for root_abbrev, base_word in pairs(M.roots) do
			if base_word:lower() == word then
				return root_abbrev:upper() -- Upper for display; adjust as needed
			end
		end

		return nil -- No match
	end

	-- Clear existing for reloads
	M.abbrevs = {}

	-- Process roots (use data.roots or fallback to empty array)
	M.roots = {}
	for _, entry in ipairs(data.roots or {}) do
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
		-- Add root to separate table if it has a base form (empty suffix)
		if vim.tbl_contains(suffix_abbrevs, "") then
			M.roots = M.roots or {} -- Init if needed
			local empty_index = vim.fn.index(suffix_abbrevs, "") + 1 -- 1-based index
			local s_word = (empty_index > 0 and suffix_words[empty_index]) or "" -- Get corresponding suffix_word
			local base_word = root_word .. s_word -- Full base word
			M.roots[root_abbrev] = base_word
		end
	end
	-- vim.notify("Loaded " .. vim.tbl_count(M.abbrevs) .. " abbrev-word pairs from JSON", vim.log.levels.INFO)

	-- Collect one-letter root abbrevs with their base words
	M.one_letter_roots = {}
	for _, entry in ipairs(data.roots or {}) do
		local root_abbrev = entry.root_abbrev:lower()
		if #root_abbrev == 1 then
			local base_word = entry.root_word
			local suffix_abbrevs = entry.suffix_abbrevs or {}
			local suffix_words = entry.suffix_words or {}
			local empty_index = vim.fn.index(suffix_abbrevs, "") + 1 -- 1-based; 0 if not found
			if empty_index > 0 then
				base_word = base_word .. (suffix_words[empty_index] or "")
			end
			M.one_letter_roots[root_abbrev] = base_word
		end
	end
	-- vim.notify(
	-- 	"Loaded " .. vim.tbl_count(M.one_letter_roots) .. " one-letter root abbrevs from JSON",
	-- 	vim.log.levels.INFO
	-- )

	-- Collect two-letter root abbrevs with their base words
	M.two_letter_roots = {}
	for _, entry in ipairs(data.roots or {}) do
		local root_abbrev = entry.root_abbrev:lower()
		if #root_abbrev == 2 then
			local base_word = entry.root_word
			local suffix_abbrevs = entry.suffix_abbrevs or {}
			local suffix_words = entry.suffix_words or {}
			local empty_index = vim.fn.index(suffix_abbrevs, "") + 1 -- 1-based; 0 if not found
			if empty_index > 0 then
				base_word = base_word .. (suffix_words[empty_index] or "")
			end
			M.two_letter_roots[root_abbrev] = base_word
		end
	end

	-- New: Load prefixes (simple loop, no complications)
	M.prefixes = {}
	for _, prefix_entry in ipairs(data.prefixes or {}) do -- Use data.prefixes (fallback to empty)
		local abbrev = prefix_entry.prefix_abbrev:lower() -- Normalize
		local word = prefix_entry.prefix_word
		M.prefixes[abbrev] = word
	end
	-- vim.notify("Loaded " .. vim.tbl_count(M.prefixes) .. " prefixes from JSON", vim.log.levels.INFO)
end

-- Call on load
load_json_data()

-- Optional: User command to reload if JSON changes
vim.api.nvim_create_user_command("ReloadAbbrevJson", load_json_data, { desc = "Reload abbrev data from JSON" })

-- Expansion logic: Lookup in table, handle capitalization
-- No dictionary checks or dynamic generation
local function try_expand(abbrev)
	if #abbrev < 2 then
		return nil
	end -- Min length to avoid noise

	local pos = 1
	local prefixes = {}
	local capitalize = false

	-- Special handling for first prefix (allow first char uppercase for capitalization)
	if #abbrev >= 2 then
		local first_char = abbrev:sub(1, 1)
		local second_char = abbrev:sub(2, 2)
		if first_char:match("[a-zA-Z]") and second_char:match("[A-Z]") then
			local cand = first_char:lower() .. second_char:lower()
			if M.prefixes[cand] then
				table.insert(prefixes, cand)
				pos = 3
				if first_char:match("[A-Z]") then
					capitalize = true
				end
			end
		end
	end

	-- Remaining prefixes: strict lowercase + uppercase
	while pos + 1 <= #abbrev do
		local first_char = abbrev:sub(pos, pos)
		local second_char = abbrev:sub(pos + 1, pos + 1)
		if first_char:match("[a-z]") and second_char:match("[A-Z]") then
			local cand = first_char .. second_char:lower()
			if M.prefixes[cand] then
				table.insert(prefixes, cand)
				pos = pos + 2
			else
				break
			end
		else
			break
		end
	end

	-- NEW: Handle capitalization for roots with no prefixes
	if #prefixes == 0 and abbrev:sub(1, 1):match("[A-Z]") then
		capitalize = true
	end

	local root_abbrev = abbrev:sub(pos):lower()
	if #root_abbrev == 0 then
		return nil
	end

	local expanded_root = M.abbrevs[root_abbrev]
	if not expanded_root then
		return nil
	end

	local prefix_str = ""
	for _, p in ipairs(prefixes) do
		prefix_str = prefix_str .. M.prefixes[p]
	end

	local full_expanded = prefix_str .. expanded_root
	if capitalize then
		full_expanded = full_expanded:sub(1, 1):upper() .. full_expanded:sub(2)
	end

	return full_expanded
end

M.try_expand = try_expand -- Export for use in completion source

-- Setup buffer-local mapping for Markdown files
local function setup_markdown_keymaps()
	--	vim.notify("Keymaps set for Markdown buffer", vim.log.levels.INFO)
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

	-- Determine if we should feed (insert) the trigger_char after expansion
	local feed_trigger = trigger_char ~= "<"

	vim.schedule(function()
		local start_col = col - #word_before + 1
		local new_line = line:sub(1, start_col - 1) .. expanded .. line:sub(col + 1)
		vim.api.nvim_set_current_line(new_line)
		vim.api.nvim_win_set_cursor(0, { pos[1], start_col + #expanded - 1 })
		if feed_trigger then
			vim.api.nvim_feedkeys(trigger_char, "n", true)
		end
	end)

	return ""
end

-- Function to list all one-letter root abbreviations in a popup
M.list_one_letter_abbrevs = function()
	local lines = {}
	for abbrev, word in pairs(M.one_letter_roots) do
		table.insert(lines, abbrev:upper() .. " → " .. word) -- Format as "AB → about"
	end
	table.sort(lines) -- Alphabetical sort for readability

	if #lines == 0 then
		vim.notify("No one-letter root abbreviations found", vim.log.levels.WARN)
		return
	end

	-- Create a buffer for the popup
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	-- Calculate dimensions (e.g., 30% of window width/height)
	local width = math.floor(vim.o.columns * 0.3)
	local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.3))
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
		title = "One-Letter Root Abbreviations",
		title_pos = "center",
	}

	-- Open the floating window
	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_win_set_option(win, "winhl", "NormalFloat:Normal,FloatBorder:Normal")

	-- Keymap to close the popup (Esc or q)
	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, silent = true })
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, silent = true })
end

-- Function to list all two-letter root abbreviations in a popup
M.list_two_letter_abbrevs = function()
	local lines = {}
	for abbrev, word in pairs(M.two_letter_roots) do
		table.insert(lines, abbrev:upper() .. " → " .. word) -- Format as "AB → about"
	end
	table.sort(lines) -- Alphabetical sort for readability

	if #lines == 0 then
		vim.notify("No two-letter root abbreviations found", vim.log.levels.WARN)
		return
	end

	-- Create a buffer for the popup
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "modifiable", false)

	-- Calculate dimensions (e.g., 30% of window width/height)
	local width = math.floor(vim.o.columns * 0.3)
	local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.3))
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
		title = "Two-Letter Root Abbreviations",
		title_pos = "center",
	}

	-- Open the floating window
	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_win_set_option(win, "winhl", "NormalFloat:Normal,FloatBorder:Normal")

	-- Keymap to close the popup (Esc or q)
	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, silent = true })
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, silent = true })
end

-- Function to list all prefix abbrevs in a popup
local function list_prefixes()
	if vim.tbl_isempty(M.prefixes) then
		vim.notify("No prefixes loaded", vim.log.levels.WARN)
		return
	end

	local lines = {}
	for abbrev, word in pairs(M.prefixes) do
		local display_abbrev = abbrev:sub(1, 1):lower() .. abbrev:sub(2, 2):upper() -- e.g., "rE" for "re"
		table.insert(lines, display_abbrev .. " -> " .. word)
	end
	table.sort(lines) -- Sort alphabetically for easier reading

	local buf = vim.api.nvim_create_buf(false, true) -- Scratch buffer
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe") -- Auto-delete on close

	local width = math.min(50, vim.o.columns - 10) -- Dynamic width, max 50 cols
	local height = math.min(#lines + 2, vim.o.lines - 10) -- Dynamic height with padding
	local opts = {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		border = "single", -- Clean border
		title = "Prefix Abbreviations",
		title_pos = "center",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_win_set_option(win, "winhl", "Normal:NormalFloat,FloatBorder:FloatBorder") -- Subtle highlighting

	-- Keymaps to close (consistent with your other lists)
	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, silent = true })
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, silent = true })
end

M.list_prefixes = list_prefixes -- Export for keymap access

return M

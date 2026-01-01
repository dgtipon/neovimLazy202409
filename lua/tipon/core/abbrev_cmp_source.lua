local source = {}

-- Constructor for the source
source.new = function()
	return setmetatable({}, { __index = source })
end

-- Trigger on lowercase letters and digits (avoids noise on symbols, but supports digit-containing abbrevs like "a2")
source.get_trigger_characters = function()
	return {
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"l",
		"m",
		"n",
		"o",
		"p",
		"q",
		"r",
		"s",
		"t",
		"u",
		"v",
		"w",
		"x",
		"y",
		"z",
		"0",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		-- Optional: Add uppercase if needed for auto-trigger on capitalized inputs
		-- "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
		-- "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	}
end

-- Availability check: Only in Markdown buffers
source.is_available = function()
	return vim.bo.filetype == "markdown"
end

-- Core completion logic: Called by cmp on trigger
source.complete = function(self, params, callback)
	local abbrev_gen = require("tipon.core.abbrev-gen") -- Reference your module
	local input = params.context.cursor_before_line:match("%w+$") -- Word before cursor
	if not input or #input < 2 then -- Min 2 chars to match your "ab" example
		return callback({})
	end

	local pos = 1
	local prefixes = {}
	local capitalize = false
	local prefix_abbrev_str = ""

	-- Special handling for first prefix (allow first char uppercase for capitalization)
	-- If the first two letters are a prefix, strip off and insert in table "prefixes"
	if #input >= 2 then
		local first_char = input:sub(1, 1)
		local second_char = input:sub(2, 2)
		if first_char:match("[a-zA-Z]") and second_char:match("[A-Z]") then
			local cand = first_char:lower() .. second_char:lower()
			if abbrev_gen.prefixes[cand] then
				table.insert(prefixes, cand)
				prefix_abbrev_str = prefix_abbrev_str .. cand
				pos = 3
				if first_char:match("[A-Z]") then
					capitalize = true
				end
			end
		end
	end

	-- Remaining prefixes: strict lowercase + uppercase; save each prefix in table "prefixes"
	while pos + 1 <= #input do
		local first_char = input:sub(pos, pos)
		local second_char = input:sub(pos + 1, pos + 1)
		if first_char:match("[a-z]") and second_char:match("[A-Z]") then
			local cand = first_char:lower() .. second_char:lower()
			if abbrev_gen.prefixes[cand] then
				table.insert(prefixes, cand)
				prefix_abbrev_str = prefix_abbrev_str .. cand
				pos = pos + 2
			else
				break
			end
		else
			break
		end
	end

	-- Expand each prefix abbreviation and concatinate into prefix word string "prefix_str"
	local prefix_str = ""
	for _, p in ipairs(prefixes) do
		prefix_str = prefix_str .. abbrev_gen.prefixes[p]
	end

	-- If no prefixes, test and set capitalization for root word
	if #prefixes == 0 and input:sub(1, 1):match("[A-Z]") then
		capitalize = true
	end

	local root_input = input:sub(pos):lower()
	-- vim.notify("root-input = " .. root_input, vim.log.levels.WARN)
	if #root_input < 1 then -- If no root after removing prefixes, exit this function
		return callback({})
	end

	-- Find the longest begining of root_input that is a root
	local root = nil
	local partial_suffix = ""
	for i = #root_input, 1, -1 do
		local candidate = root_input:sub(1, i)
		-- vim.notify("candidate = " .. candidate, vim.log.levels.WARN)
		if abbrev_gen.roots[candidate] then
			root = candidate
			-- vim.notify("root = " .. root, vim.log.levels.WARN)
			partial_suffix = root_input:sub(i + 1)
			break
		end
	end

	local items = {}

	-- If a root is found, add matching suffixed forms incrementally (exact + next letter extensions)
	if root then
		-- Find the matching entry in json_data
		local entry = nil
		for _, e in ipairs(abbrev_gen.json_data) do
			if e.root_abbrev:lower() == root then
				entry = e
				break
			end
		end
		if entry then
			local suffix_abbrevs = entry.suffix_abbrevs or {}
			local suffix_words = entry.suffix_words or {}
			local matched_suffixes = {}
			for i, s_abbrev in ipairs(suffix_abbrevs) do
				if s_abbrev:find(partial_suffix, 1, true) == 1 and #s_abbrev <= #partial_suffix + 1 then
					local full_abbrev = root .. s_abbrev
					local s_word = suffix_words[i] or ""
					local full_word = prefix_str .. entry.root_word .. s_word
					local adjusted_word = capitalize and (full_word:sub(1, 1):upper() .. full_word:sub(2)) or full_word
					table.insert(matched_suffixes, {
						label = (prefix_abbrev_str .. full_abbrev) .. "_" .. adjusted_word,
						kind = vim.lsp.protocol.CompletionItemKind.Text,
						insertText = adjusted_word,
						documentation = (
							s_abbrev == "" and "Base root expansion"
							or "Suffix: " .. s_abbrev:upper() .. " → " .. s_word
						),
					})
				end
			end
			-- Sort by label for consistent order
			table.sort(matched_suffixes, function(a, b)
				return a.label < b.label
			end)
			for _, item in ipairs(matched_suffixes) do
				table.insert(items, item)
			end
		end
	end

	-- Add partial/fuzzy matches on other roots (if not fully matched by suffixes)
	local lookup_table = abbrev_gen.roots -- Always use roots for partial matches
	for abbrev, word in pairs(lookup_table) do
		if abbrev:find(root_input, 1, true) == 1 and abbrev ~= root_input then
			local full_word = prefix_str .. word
			local adjusted_word = capitalize and (full_word:sub(1, 1):upper() .. full_word:sub(2)) or full_word
			table.insert(items, {
				label = (prefix_abbrev_str .. abbrev) .. "_" .. adjusted_word,
				kind = vim.lsp.protocol.CompletionItemKind.Text,
				insertText = adjusted_word,
				documentation = "Partial root match: " .. abbrev,
			})
		end
	end

	-- Optional: Fallback to dynamic try_expand if no matches (integrates your existing logic)
	if #items == 0 then
		local dynamic_word = abbrev_gen.try_expand(input) -- Pass full input; try_expand handles prefixes
		if dynamic_word then
			table.insert(items, {
				label = input:lower() .. "_" .. dynamic_word, -- Consistent format
				kind = vim.lsp.protocol.CompletionItemKind.Text,
				insertText = dynamic_word, -- Insert only the word
				documentation = "Dynamic expansion",
			})
		end
	end

	callback(items)
end

return source

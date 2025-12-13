local source = {}

-- Constructor for the source
source.new = function()
	return setmetatable({}, { __index = source })
end

-- Trigger on lowercase letters (avoids noise on symbols)
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

	-- Remaining prefixes: strict lowercase + uppercase
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

	-- NEW: Handle capitalization for roots with no prefixes
	if #prefixes == 0 and input:sub(1, 1):match("[A-Z]") then
		capitalize = true
	end

	local root_input = input:sub(pos):lower()
	-- If no root after prefixes and input is short, skip
	if #root_input < 1 then
		return callback({})
	end

	local items = {}
	local use_roots_only = #root_input <= 3 -- Limit to roots for short inputs
	local lookup_table = use_roots_only and abbrev_gen.roots or abbrev_gen.abbrevs

	-- Build prefix word string
	local prefix_str = ""
	for _, p in ipairs(prefixes) do
		prefix_str = prefix_str .. abbrev_gen.prefixes[p]
	end

	-- Exact match (always check full abbrevs for precision)
	local exact_word = abbrev_gen.abbrevs[root_input]
	if exact_word then
		local full_word = prefix_str .. exact_word
		local adjusted_word = capitalize and (full_word:sub(1, 1):upper() .. full_word:sub(2)) or full_word
		table.insert(items, {
			label = (prefix_abbrev_str .. root_input) .. "_" .. adjusted_word, -- Show abbrev_word for cue
			kind = vim.lsp.protocol.CompletionItemKind.Text,
			insertText = adjusted_word, -- Insert only the word
			documentation = "Exact abbrev expansion from JSON",
		})
	end

	-- Prefix/fuzzy matches (using roots or full based on input length)
	for abbrev, word in pairs(lookup_table) do
		if abbrev:find(root_input, 1, true) == 1 and abbrev ~= root_input then
			local full_word = prefix_str .. word
			local adjusted_word = capitalize and (full_word:sub(1, 1):upper() .. full_word:sub(2)) or full_word
			table.insert(items, {
				label = (prefix_abbrev_str .. abbrev) .. "_" .. adjusted_word, -- Show abbrev_word for cue
				kind = vim.lsp.protocol.CompletionItemKind.Text,
				insertText = adjusted_word, -- Insert only the word
				documentation = "Partial match: " .. abbrev,
			})
		end
	end

	-- Optional: Fallback to dynamic try_expand if no matches (integrates your existing logic)
	local dynamic_word = abbrev_gen.try_expand(input) -- Pass full input; try_expand handles prefixes
	if
		dynamic_word
		and not vim.tbl_contains(
			vim.tbl_map(function(item)
				return item.insertText
			end, items),
			dynamic_word
		)
	then
		table.insert(items, {
			label = input:lower() .. "_" .. dynamic_word, -- Consistent format
			kind = vim.lsp.protocol.CompletionItemKind.Text,
			insertText = dynamic_word, -- Insert only the word
			documentation = "Dynamic expansion",
		})
	end

	callback(items)
end
return source

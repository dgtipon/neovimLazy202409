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

	local items = {}
	local lower_input = input:lower()
	local is_capitalized = input:sub(1, 1):match("%u") ~= nil
	local use_roots_only = #lower_input <= 3 -- Limit to roots for short inputs

	-- Lookup table to use (roots for short, full abbrevs for long)
	local lookup_table = use_roots_only and abbrev_gen.roots or abbrev_gen.abbrevs

	-- Exact match (always check full abbrevs for precision)
	local exact_word = abbrev_gen.abbrevs[lower_input]
	if exact_word then
		local adjusted_word = is_capitalized and (exact_word:sub(1, 1):upper() .. exact_word:sub(2)) or exact_word
		table.insert(items, {
			label = lower_input .. "_" .. adjusted_word, -- Show abbrev_word for cue
			kind = vim.lsp.protocol.CompletionItemKind.Text,
			insertText = adjusted_word, -- Insert only the word
			documentation = "Exact abbrev expansion from JSON",
		})
	end

	-- Prefix/fuzzy matches (using roots or full based on input length)
	for abbrev, word in pairs(lookup_table) do
		if abbrev:find(lower_input, 1, true) == 1 and abbrev ~= lower_input then
			local adjusted_word = is_capitalized and (word:sub(1, 1):upper() .. word:sub(2)) or word
			table.insert(items, {
				label = abbrev .. "_" .. adjusted_word, -- Show abbrev_word for cue
				kind = vim.lsp.protocol.CompletionItemKind.Text,
				insertText = adjusted_word, -- Insert only the word
				documentation = "Partial match: " .. abbrev,
			})
		end
	end

	-- Add suffix variants if input is an exact root abbrev
	if abbrev_gen.roots[lower_input] then -- Confirm it's a root
		for _, entry in ipairs(abbrev_gen.json_data or {}) do
			if entry.root_abbrev:lower() == lower_input then
				local root_word = entry.root_word
				local suffix_abbrevs = entry.suffix_abbrevs or {}
				local suffix_words = entry.suffix_words or {}
				for i, s_abbrev in ipairs(suffix_abbrevs) do
					if s_abbrev ~= "" then -- Skip base (already added as exact)
						local full_abbrev = lower_input .. s_abbrev:lower()
						local s_word = suffix_words[i] or ""
						local full_word = root_word .. s_word
						local adjusted_word = is_capitalized and (full_word:sub(1, 1):upper() .. full_word:sub(2))
							or full_word
						-- Check for dupes (e.g., if partial already added it)
						if
							not vim.tbl_contains(
								vim.tbl_map(function(item)
									return item.insertText
								end, items),
								adjusted_word
							)
						then
							table.insert(items, {
								label = full_abbrev .. "_" .. adjusted_word, -- Show full_abbrev_full_word
								kind = vim.lsp.protocol.CompletionItemKind.Text,
								insertText = adjusted_word, -- Insert only the word
								documentation = "Suffix expansion: " .. s_abbrev,
							})
						end
					end
				end
				break -- Assume unique roots
			end
		end
	end

	-- Optional: Fallback to dynamic try_expand if no matches (integrates your existing logic)
	local dynamic_word = abbrev_gen.try_expand(input)
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
			label = lower_input .. "_" .. dynamic_word, -- Consistent format
			kind = vim.lsp.protocol.CompletionItemKind.Text,
			insertText = dynamic_word, -- Insert only the word
			documentation = "Dynamic expansion",
		})
	end

	callback(items)
end
return source

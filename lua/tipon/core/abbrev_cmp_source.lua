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

	-- Exact match from M.abbrevs
	local exact_word = abbrev_gen.abbrevs[lower_input]
	if exact_word then
		local adjusted_word = is_capitalized and (exact_word:sub(1, 1):upper() .. exact_word:sub(2)) or exact_word
		table.insert(items, {
			label = adjusted_word,
			kind = vim.lsp.protocol.CompletionItemKind.Text,
			insertText = adjusted_word,
			documentation = "Exact abbrev expansion from JSON",
		})
	end

	-- Prefix/fuzzy matches for broader suggestions (e.g., "ab" → all "ab*" words)
	for abbrev, word in pairs(abbrev_gen.abbrevs) do
		if abbrev:find(lower_input, 1, true) == 1 and abbrev ~= lower_input then
			local adjusted_word = is_capitalized and (word:sub(1, 1):upper() .. word:sub(2)) or word
			table.insert(items, {
				label = adjusted_word,
				kind = vim.lsp.protocol.CompletionItemKind.Text,
				insertText = adjusted_word,
				documentation = "Partial match: " .. abbrev,
			})
		end
	end

	-- Optional: Fallback to dynamic try_expand if no matches (integrates your existing logic)
	local dynamic_word = abbrev_gen.try_expand(input)
	if
		dynamic_word and not vim.tbl_contains(
			vim.tbl_map(function(item)
				return item.label
			end, items),
			dynamic_word
		)
	then
		table.insert(items, {
			label = dynamic_word,
			kind = vim.lsp.protocol.CompletionItemKind.Text,
			insertText = dynamic_word,
			documentation = "Dynamic expansion",
		})
	end

	callback(items)
end

return source

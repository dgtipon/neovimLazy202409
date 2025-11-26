-- Abbrev-gen: On-the-fly abbreviation expansion for Markdown (With dictionary-validated multi-step suffix generation)

vim.notify("Abbrev-gen version 1.9.1 loaded (optimized suffix candidates)", vim.log.levels.INFO)

local M = {} -- Declare M early, at the top

M.roots_by_abbrev = require("tipon.core.abbrev-roots")

-- Suffix map: code → {candidates = {func1, func2, ...}} (optimized: fewer/more accurate)
M.suffix_map = {
	["n"] = { candidates = {
		function(r)
			return r .. "ion"
		end,
	} },
	["ns"] = { candidates = {
		function(r)
			return r .. "ions"
		end,
	} },
	["v"] = { candidates = {
		function(r)
			return r:gsub("e$", "") .. "ive"
		end,
	} },
	["vs"] = { candidates = {
		function(r)
			return r:gsub("e$", "") .. "ives"
		end,
	} },
	["vy"] = { candidates = {
		function(r)
			return r:gsub("e$", "") .. "ively"
		end,
	} },
	["b"] = { candidates = {
		function(r)
			return r .. "able"
		end,
	} },
	["bs"] = { candidates = {
		function(r)
			return r .. "ables"
		end,
	} },
	["m"] = { candidates = {
		function(r)
			return r .. "ment"
		end,
	} },
	["ms"] = { candidates = {
		function(r)
			return r .. "ments"
		end,
	} },
	["r"] = { candidates = {
		function(r)
			return r .. "er"
		end,
	} },
	["rs"] = { candidates = {
		function(r)
			return r .. "ers"
		end,
	} },
	["y"] = { candidates = {
		function(r)
			return r .. "y"
		end,
	} },
	["ly"] = { candidates = {
		function(r)
			return r .. "ly"
		end,
	} },
	["ss"] = { candidates = {
		function(r)
			return r .. "ness"
		end,
	} },
	["sss"] = { candidates = {
		function(r)
			return r .. "nesses"
		end,
	} },
	-- Optimized: Plural ("s") - Single smart function, always 1 candidate
	["s"] = {
		candidates = {
			function(r)
				if r:match("[^aeiou]y$") then
					return r:sub(1, -2) .. "ies"
				elseif r:match("[sxz]$") or r:match("[^aeiouy]ch$") or r:match("[^aeiouy]sh$") then
					return r .. "es"
				else
					return r .. "s"
				end
			end,
		},
	},
	-- Optimized: Past tense ("d") - 1-2 candidates, smart order
	["d"] = {
		candidates = {
			function(r) -- Most common: Drop "e" + "d" if ends "e", else "ed"
				if r:match("e$") then
					return r:sub(1, -2) .. "d"
				else
					return r .. "ed"
				end
			end,
			function(r) -- For "y" endings
				if r:match("[^aeiou]y$") then
					return r:sub(1, -2) .. "ied"
				end
			end, -- Nil if not applicable (loop skips if return nil)
		},
	},
	-- Optimized: Gerund ("g") - 1-3 candidates, non-doubled first for common cases
	["g"] = {
		candidates = {
			function(r) -- First: Drop "e" + "ing" (e.g., "accelerating")
				local base = r:gsub("e$", "")
				return base .. "ing"
			end,
			function(r) -- Second: Drop "e", double consonant if CVC pattern (strict for short words)
				local base = r:gsub("e$", "")
				if #base <= 6 and base:match("[^aeiou][aeiou][^aeiou]$") and not base:match("[wxy]$") then -- Added length check to avoid over-doubling long words
					base = base .. base:sub(-1)
				end
				return base .. "ing"
			end,
			function(r) -- Rare fallback: Keep "e" + "ing"
				return r .. "ing"
			end,
		},
	},
	-- Add more as needed (keep simple suffixes as single funcs)
}

-- Prefix map: code → prefix (simple string concat)
M.prefix_map = {
	["d"] = "dis",
	["r"] = "re",
	["u"] = "un",
	["i"] = "in",
	["e"] = "en",
}

-- Cache for validated expansions (session-local)
M.abbrevs = {}

-- Load overrides from pop.txt
local function load_pop_overrides()
	local pop_path = vim.fn.stdpath("config") .. "/pop.txt"
	local file = io.open(pop_path, "r")
	if not file then
		vim.notify("pop.txt not found; no overrides loaded", vim.log.levels.WARN)
		return
	end
	local content = file:read("*a")
	file:close()
	for entry in content:gmatch("[^\t\n]+") do -- Handle tabs or newlines
		local abbrev, word = entry:match("^(%S+)_(%S+)$")
		if abbrev and word then
			M.abbrevs[abbrev:lower()] = word -- Store lower for case-insensitivity
			--			vim.notify("Overrode " .. abbrev .. " → " .. word .. " from pop.txt", vim.log.levels.DEBUG)
		end
	end
end
load_pop_overrides()

-- Function to check if word is in dictionary (requires spell enabled)
local function is_valid_word(word)
	local bad = vim.fn.spellbadword(word)[1] -- [1] is the badword ("" if good)
	local result = (bad == "") and "good" or "bad"
	vim.notify("Checking word: " .. word .. " - result: " .. result, vim.log.levels.DEBUG) -- Temp debug
	return bad == ""
end

-- Function to try expanding an abbreviation string
M.try_expand = function(abbrev)
	local lower_abbrev = abbrev:lower()
	local is_capitalized = (abbrev:sub(1, 1):upper() == abbrev:sub(1, 1))
	vim.notify("try_expand called with abbrev: " .. lower_abbrev, vim.log.levels.DEBUG)

	-- Check cache/override first (fast path)
	if M.abbrevs[lower_abbrev] then
		local expanded = M.abbrevs[lower_abbrev]
		if is_capitalized then
			expanded = expanded:sub(1, 1):upper() .. expanded:sub(2)
		end
		return expanded
	end

	-- Parse for prefix + base + suffix (cheap string ops)
	local prefix_code, suffix_code, base_abbrev = "", "", lower_abbrev
	for code in pairs(M.prefix_map) do
		if lower_abbrev:sub(1, #code) == code then
			prefix_code = code
			base_abbrev = lower_abbrev:sub(#code + 1)
			break
		end
	end
	for code in pairs(M.suffix_map) do
		if base_abbrev:sub(-#code) == code then
			suffix_code = code
			base_abbrev = base_abbrev:sub(1, -#code - 1)
			break
		end
	end

	-- Early bail: No root? Not an abbrev, skip all generation/lookups
	local root = M.roots_by_abbrev[base_abbrev]
	if not root then
		vim.notify("No root for base: " .. base_abbrev .. " - not an abbrev", vim.log.levels.DEBUG)
		return nil
	end

	-- Apply prefix if any
	local base_word = root
	if prefix_code ~= "" then
		base_word = M.prefix_map[prefix_code] .. root
	end

	-- No suffix? Validate base and cache
	if suffix_code == "" then
		if is_valid_word(base_word) then
			M.abbrevs[lower_abbrev] = base_word
			local expanded = base_word
			if is_capitalized then
				expanded = expanded:sub(1, 1):upper() .. expanded:sub(2)
			end
			return expanded
		else
			return nil
		end
	end

	-- Generate and validate suffix candidates (only if valid abbrev)
	local suffix_info = M.suffix_map[suffix_code]
	if not suffix_info then
		return nil
	end
	local query_count = 0
	for _, candidate_func in ipairs(suffix_info.candidates) do
		local candidate = candidate_func(base_word)
		if candidate then -- Skip if func returns nil (conditional)
			query_count = query_count + 1
			vim.notify("Trying candidate: " .. candidate .. " (query " .. query_count .. ")", vim.log.levels.DEBUG) -- Temp debug
			if is_valid_word(candidate) then
				M.abbrevs[lower_abbrev] = candidate
				local expanded = candidate
				if is_capitalized then
					expanded = expanded:sub(1, 1):upper() .. expanded:sub(2)
				end
				vim.notify("Valid expansion found: " .. expanded, vim.log.levels.INFO)
				return expanded
			end
		end
	end

	vim.notify("No valid expansion for abbrev: " .. abbrev, vim.log.levels.WARN)
	return nil
end

-- Setup buffer-local mapping for Markdown files
local function setup_markdown_keymaps()
	vim.notify("Keymaps set for Markdown buffer", vim.log.levels.INFO) -- Confirm callback ran
	vim.wo.spell = true -- Enable spell locally for dict checks
	vim.opt_local.spelllang = "en_us" -- Or en_gb, etc.

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

-- Robustness: If current buffer is already markdown (timing issue), call immediately
if vim.bo.filetype == "markdown" then
	setup_markdown_keymaps()
end

-- Expansion handler (unchanged from original)
M.expand_abbrev = function(trigger_char)
	trigger_char = trigger_char or " "
	vim.notify("expand_abbrev triggered with char: >" .. trigger_char .. "<", vim.log.levels.DEBUG)

	local pos = vim.api.nvim_win_get_cursor(0)
	local line = vim.api.nvim_get_current_line()
	local col = pos[2]
	local word_before = line:sub(1, col):match("%w+$")

	if not word_before then
		vim.notify("No word detected - returning " .. trigger_char, vim.log.levels.DEBUG)
		return trigger_char
	end

	local expanded = M.try_expand(word_before)
	if not expanded then
		vim.notify("No expansion for '" .. word_before .. "' - returning " .. trigger_char, vim.log.levels.DEBUG)
		return trigger_char
	end

	vim.notify("Expanding '" .. word_before .. "' to '" .. expanded .. "'", vim.log.levels.INFO)

	vim.schedule(function()
		local start_col = col - #word_before + 1
		local new_line = line:sub(1, start_col - 1) .. expanded .. line:sub(col + 1)
		vim.api.nvim_set_current_line(new_line)
		vim.api.nvim_win_set_cursor(0, { pos[1], start_col + #expanded - 1 })
		vim.api.nvim_feedkeys(trigger_char, "n", true)
	end)

	return ""
end

-- Optional: Regenerate pop.txt (updated to use candidates for better generation)
local function update_pop_txt()
	local pop_content = {}
	for base_abbrev, root in pairs(M.roots_by_abbrev) do
		table.insert(pop_content, base_abbrev .. "_" .. root)
		for s_code, info in pairs(M.suffix_map) do
			for _, func in ipairs(info.candidates) do
				local derived_abbrev = base_abbrev .. s_code
				local derived_word = func(root)
				if derived_word then -- Skip nils
					table.insert(pop_content, derived_abbrev .. "_" .. derived_word)
				end
			end
		end
		for p_code, prefix in pairs(M.prefix_map) do
			local prefixed_abbrev = p_code .. base_abbrev
			local prefixed_word = prefix .. root
			table.insert(pop_content, prefixed_abbrev .. "_" .. prefixed_word)
			for s_code, info in pairs(M.suffix_map) do
				for _, func in ipairs(info.candidates) do
					local combo_abbrev = p_code .. base_abbrev .. s_code
					local combo_word = func(prefix .. root)
					if combo_word then
						table.insert(pop_content, combo_abbrev .. "_" .. combo_word)
					end
				end
			end
		end
	end
	table.sort(pop_content)
	local pop_path = vim.fn.stdpath("config") .. "/pop.txt"
	local file = io.open(pop_path, "w")
	if file then
		file:write(table.concat(pop_content, "\t"))
		file:close()
		vim.notify("pop.txt updated at " .. pop_path, vim.log.levels.INFO)
	else
		vim.notify("Failed to write pop.txt", vim.log.levels.ERROR)
	end
end

vim.api.nvim_create_user_command("UpdatePopTxt", update_pop_txt, {})

return M

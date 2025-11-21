-- Abbrev-gen: On-the-fly abbreviation expansion for Markdown

vim.notify("Abbrev-gen file required", vim.log.levels.INFO)

local M = {} -- Declare M early, at the top

-- Root table: From your pop.txt (abbrev → word for reverse lookup; ~500 entries)
M.roots_by_abbrev = {
	["5g"] = "/",
	["5gf"] = "/fare",
	["A2"] = "Almost",
	["amr"] = "America",
	["N"] = "And",
	["A3"] = "Anything",
	["R"] = "Are",
	["T"] = "The",
	["Ubts"] = "Usabilities",
	["Ubty"] = "Usability",
	["Ub"] = "Usable",
	["Ubs"] = "Usables",
	["Uby"] = "Usably",
	["Ua"] = "Usage",
	["Uas"] = "Usages",
	["U"] = "Use",
	["Ud"] = "Used",
	["Uf"] = "Useful",
	["Ufss"] = "Usefulness",
	["Ufsss"] = "Usefulnesses",
	["Uss"] = "Useless",
	["Ur"] = "User",
	["Urs"] = "Users",
	["Us"] = "Uses",
	["Ug"] = "Using",
	["Ul"] = "Usual",
	["Uy"] = "Usually",
	["V"] = "Very",
	["W"] = "With",
	["wef3"] = "World_Economic_Forum",
	["Y"] = "You",
	["abn"] = "abandon",
	["abl"] = "ability",
	["abm"] = "abominate",
	["ab"] = "about",
	["abv"] = "above",
	["abr"] = "abrupt",
	["abo"] = "absolute",
	["abb"] = "absorb",
	["abs"] = "abstract",
	["abd"] = "abundant",
	["abu"] = "abuse",
	["ace"] = "accelerate",
	["acp"] = "accept",
	["acs"] = "access",
	["acc"] = "accident",
	["acka"] = "accommodate",
	["ackp"] = "accompany",
	["ackh"] = "accomplish",
	["aco"] = "accord",
	["acn"] = "account",
	["acmu"] = "accumulate",
	["acy"] = "accuracy",
	["acr"] = "accurate",
	["acu"] = "accuse",
	["acm"] = "accustom",
	["ach"] = "achieve",
	["ack"] = "acknowledge",
	["acq"] = "acquire",
	["act"] = "act",
	["aca"] = "activate",
	["acv"] = "active",
	["ays"] = "activities",
	["ay"] = "activity",
	["acl"] = "actual",
	["adp"] = "adapt",
	["add"] = "add",
	["adc"] = "addict",
	["adr"] = "address",
	["adq"] = "adequate",
	["adj"] = "adjust",
	["adm"] = "administrate",
	["adi"] = "admit",
	["adl"] = "adolescence",
	["adnz"] = "advance",
	["adg"] = "advantage",
	["ade"] = "adventure",
	["adv"] = "adverse",
	["adt"] = "advertise",
	["ads"] = "advise",
	["afb"] = "affable",
	["afc"] = "affect",
	["afi"] = "affiliate",
	["afr"] = "affirm",
	["afl"] = "afflict",
	["afu"] = "affluent",
	["afo"] = "afford",
	["afd"] = "afraid",
	["af"] = "after",
	["ag"] = "against",
	["agn"] = "agency",
	["ags"] = "aggressive",
	["agr"] = "agree",
	["alr"] = "alarm",
	["alg"] = "algorithm",
	["alk"] = "alike",
	["alv"] = "alleviate",
	["ali"] = "alliance",
	["alo"] = "allocate",
	["alw"] = "allow",
	["a2"] = "almost",
	["alp"] = "alphabet",
	["a2r"] = "already",
	["al"] = "also",
	["alt"] = "alter",
	["alc"] = "altercate",
	["aln"] = "alternate",
	["a2t"] = "although",
	["a2w"] = "always",
	["amz"] = "amaze",
	["amg"] = "among",
	["amn"] = "amount",
	["amp"] = "amplify",
	["ang"] = "analog",
	["anl"] = "analyze",
	["anc"] = "ancestor",
	["ani"] = "ancient",
	["n"] = "and",
	["anst"] = "anesthesia",
	["anm"] = "animal",
	["anh"] = "annihilate",
	["ann"] = "announce",
	["anu"] = "anonymous",
	["ant"] = "another",
	["ans"] = "answer",
	["ana"] = "antagonize",
	["anx"] = "anxiety",
	["a3d"] = "any day",
	["a3b"] = "anybody",
	["a3o"] = "anyone",
	["a3"] = "anything",
	["a3t"] = "anytime",
	["a3w"] = "anyway",
	["a3wh"] = "anywhere",
	["apy"] = "apocalypse",
	["apo"] = "apology",
	["apt"] = "apparatus",
	["apr"] = "appear",
	["aplc"] = "applicate",
	["apl"] = "apply",
	["apn"] = "appoint",
	["aps"] = "appraise",
	["azc"] = "appreciate",
	["azh"] = "apprehend",
	["azn"] = "apprentice",
	["aqc"] = "approach",
	["aqp"] = "appropriate",
	["aqv"] = "approve",
	["aqx"] = "approximate",
	["arb"] = "arbitrary",
	["arc"] = "architecture",
	["r"] = "are",
	["arg"] = "argue",
	["arn"] = "around",
	["arr"] = "arrange",
	["ari"] = "article",
	["arf"] = "artificial",
	["ask"] = "ask",
	["asp"] = "aspect",
	["asn"] = "assassin",
	["asr"] = "assert",
	["ass"] = "assess",
	["asg"] = "assign",
	["asl"] = "assimilate",
	["asi"] = "assist",
	["asc"] = "associate",
	["asm"] = "assume",
	["ash"] = "astonish",
	["asu"] = "astound",
	["ast"] = "astronomy",
	["asy"] = "asynchrony",
	["atm"] = "atomic",
	["ato"] = "atrocity",
	["ata"] = "attach",
	["atc"] = "attack",
	["atp"] = "attempt",
	["atn"] = "attend",
	["atnn"] = "attention",
	["att"] = "attitude",
	["atr"] = "attract",
	["ati"] = "attribute",
	["agm"] = "augment",
	["ath"] = "author",
	["am2"] = "automate",
	["avl"] = "avail",
	["avd"] = "avoid",
	["awk"] = "awake",
	["awa"] = "award",
	["awr"] = "aware",
	["az"] = "awareness",
	["aw"] = "away",
	["aws"] = "awesome",
	["bck"] = "back",
	["bg2"] = "background",
	["blc"] = "balance",
	["brr"] = "barrier",
	["bsc"] = "basic",
	["bf2"] = "battlefield_",
	["bg3"] = "battleground",
	["bz"] = "bazaar",
	["bra"] = "bear",
	["btf"] = "beautify",
	["bty"] = "beauty",
	["bcm"] = "became",
	["bcs"] = "because",
	["bk"] = "become",
	["bn"] = "been",
	["bfr"] = "before",
	["bgn"] = "begin",
	-- (truncate for brevity; include all your roots here as before)
	["zr"] = "zero",
	["zzzzz"] = "zzzzz",
	["zzzzzz"] = "zzzzzz",
}

-- Suffix map: code → suffix (inverse of original rules)
M.suffix_map = {
	["n"] = "ion",
	["ns"] = "ions",
	["v"] = "ive",
	["vs"] = "ives",
	["vy"] = "ively",
	["b"] = "able",
	["bs"] = "ables",
	["m"] = "ment",
	["ms"] = "ments",
	["d"] = "ed",
	["g"] = "ing",
	["r"] = "er",
	["rs"] = "ers",
	["y"] = "y", -- For adjectives/adverbs
	["ly"] = "ly",
	["ss"] = "ness",
	["sss"] = "nesses",
	-- Add any missing from your original suffix_rules
}

-- Prefix map: code → prefix
M.prefix_map = {
	["d"] = "dis",
	["r"] = "re",
	["u"] = "un",
	["i"] = "in",
	["e"] = "en",
	-- Add any missing
}

-- Setup buffer-local mapping for Markdown files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.notify("Markdown FileType autocmd fired - setting up expansion", vim.log.levels.INFO) -- Debug: Confirm autocmd runs

		-- Debug: Confirm keymap is being set
		vim.notify("Setting insert-mode mapping for <C-e>", vim.log.levels.DEBUG)

		vim.keymap.set("i", "<C-e>", function()
			M.expand_abbrev()
		end, { buffer = true })

		-- Map common end-of-word triggers (space, punctuation)
		local triggers = { " ", ",", ";", ":", "." }
		for _, trigger in ipairs(triggers) do
			vim.keymap.set("i", trigger, function()
				M.expand_abbrev(trigger)
			end, { buffer = true })
		end
	end,
})

-- Expansion handler (called on triggers in insert mode)
M.expand_abbrev = function(trigger_char)
	trigger_char = trigger_char or " " -- Default to space if not provided

	vim.notify("expand_abbrev function triggered with char: " .. trigger_char, vim.log.levels.INFO) -- Debug: Confirm function runs

	local pos = vim.api.nvim_win_get_cursor(0)
	local line = vim.api.nvim_get_current_line()
	local col = pos[2]
	local word_before = line:sub(1, col):match("%w+$")
	vim.notify("Captured word before cursor: " .. (word_before or "NONE"), vim.log.levels.DEBUG) -- Debug: What was detected?

	if not word_before then
		vim.notify("No word detected before cursor - inserting " .. trigger_char, vim.log.levels.DEBUG)
		vim.api.nvim_feedkeys(trigger_char, "n", true)
		return
	end

	local expanded = M.try_expand(word_before)
	if not expanded then
		vim.notify("No expansion found for '" .. word_before .. "' - inserting " .. trigger_char, vim.log.levels.DEBUG)
		vim.api.nvim_feedkeys(trigger_char, "n", true)
		return
	end

	vim.notify("Expanding '" .. word_before .. "' to '" .. expanded .. "'", vim.log.levels.INFO)

	-- Replace the abbreviation
	local start_col = col - #word_before + 1
	local new_line = line:sub(1, start_col - 1) .. expanded .. line:sub(col + 1)
	vim.api.nvim_set_current_line(new_line)

	-- Move cursor to end of expanded word
	vim.api.nvim_win_set_cursor(0, { pos[1], start_col + #expanded - 1 })

	-- Insert the trigger char after
	vim.api.nvim_feedkeys(trigger_char, "n", true)
end

-- Function to try expanding an abbreviation string
M.try_expand = function(abbrev)
	vim.notify("try_expand called with abbrev: " .. abbrev, vim.log.levels.DEBUG) -- Debug: Confirm input

	local root = M.roots_by_abbrev[abbrev]
	if root then
		vim.notify("Matched base root: " .. root, vim.log.levels.DEBUG)
		return root
	end

	-- Check for suffix
	for code, suffix in pairs(M.suffix_map) do
		if abbrev:sub(-#code) == code then
			local base_abbrev = abbrev:sub(1, -#code - 1)
			vim.notify("Testing suffix code '" .. code .. "' with base: " .. base_abbrev, vim.log.levels.DEBUG)
			root = M.roots_by_abbrev[base_abbrev]
			if root then
				local expanded = root:gsub("e$", "") .. suffix
				vim.notify("Suffix match found: " .. expanded, vim.log.levels.DEBUG)
				return expanded
			end
		end
	end

	-- Check for prefix
	for code, prefix in pairs(M.prefix_map) do
		if abbrev:sub(1, #code) == code then
			local rest = abbrev:sub(#code + 1)
			vim.notify("Testing prefix code '" .. code .. "' with rest: " .. rest, vim.log.levels.DEBUG)
			root = M.roots_by_abbrev[rest]
			if root then
				local expanded = prefix .. root
				vim.notify("Prefix match found: " .. expanded, vim.log.levels.DEBUG)
				return expanded
			end
			-- Prefix + suffix
			for s_code, suffix in pairs(M.suffix_map) do
				if rest:sub(-#s_code) == s_code then
					local base_abbrev = rest:sub(1, -#s_code - 1)
					vim.notify(
						"Testing prefix+suffix: prefix '"
							.. code
							.. "', suffix '"
							.. s_code
							.. "', base: "
							.. base_abbrev,
						vim.log.levels.DEBUG
					)
					root = M.roots_by_abbrev[base_abbrev]
					if root then
						local expanded = prefix .. root:gsub("e$", "") .. suffix
						vim.notify("Prefix+suffix match found: " .. expanded, vim.log.levels.DEBUG)
						return expanded
					end
				end
			end
		end
	end

	vim.notify("No match found for abbrev: " .. abbrev, vim.log.levels.WARN) -- Warn if no expansion
	return nil
end

-- Expansion handler (called on <C-e> in insert mode)
M.expand_abbrev = function()
	vim.notify("expand_abbrev function triggered", vim.log.levels.INFO) -- Debug: Confirm function runs

	local pos = vim.api.nvim_win_get_cursor(0)
	local line = vim.api.nvim_get_current_line()
	local col = pos[2]
	local word_before = line:sub(1, col):match("%w+$")
	vim.notify("Captured word before cursor: " .. (word_before or "NONE"), vim.log.levels.DEBUG) -- Debug: What was detected?

	if not word_before then
		vim.notify("No word detected before cursor - inserting plain space", vim.log.levels.DEBUG)
		return [[<Space>]]
	end

	local expanded = M.try_expand(word_before)
	if not expanded then
		vim.notify("No expansion found for '" .. word_before .. "' - inserting plain space", vim.log.levels.DEBUG)
		return [[<Space>]]
	end

	vim.notify("Expanding '" .. word_before .. "' to '" .. expanded .. "'", vim.log.levels.INFO)

	-- Replace the abbreviation
	local start_col = col - #word_before + 1
	local new_line = line:sub(1, start_col - 1) .. expanded .. line:sub(col + 1)
	vim.api.nvim_set_current_line(new_line)

	-- Move cursor to end of expanded word + space position
	vim.api.nvim_win_set_cursor(0, { pos[1], start_col + #expanded - 1 })

	return [[<Space>]]
end

-- Optional: Regenerate pop.txt (unchanged from before)
local function update_pop_txt()
	local pop_content = {}
	for base_abbrev, root in pairs(M.roots_by_abbrev) do
		table.insert(pop_content, base_abbrev .. "_" .. root)
		for s_code, suffix in pairs(M.suffix_map) do
			local derived_abbrev = base_abbrev .. s_code
			local derived_word = root:gsub("e$", "") .. suffix
			table.insert(pop_content, derived_abbrev .. "_" .. derived_word)
		end
		for p_code, prefix in pairs(M.prefix_map) do
			local prefixed_abbrev = p_code .. base_abbrev
			local prefixed_word = prefix .. root
			table.insert(pop_content, prefixed_abbrev .. "_" .. prefixed_word)
			for s_code, suffix in pairs(M.suffix_map) do
				local combo_abbrev = p_code .. base_abbrev .. s_code
				local combo_word = prefix .. root:gsub("e$", "") .. suffix
				table.insert(pop_content, combo_abbrev .. "_" .. combo_word)
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

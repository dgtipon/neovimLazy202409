-- ~/.config/nvim/lua/tipon/tests/abbrev_gen_spec.lua
local abbrev_gen = require("tipon.core.abbrev-gen") -- Your module

describe("abbrev-gen suffix expansions", function()
	local roots = abbrev_gen.roots_by_abbrev
	local suffixes = abbrev_gen.suffix_map

	-- Helper with error handling for optimized suffix_map
	local function safe_expected_expansion(root, suffix)
		local base = root:gsub("e$", "")
		local success, result = pcall(function()
			if type(suffix) == "string" then
				return base .. suffix
			elseif type(suffix) == "table" and type(suffix.candidates) == "function" then
				local candidates = suffix.candidates(base)
				if type(candidates) == "table" and #candidates > 0 then
					print("Candidates generated: " .. table.concat(candidates, ", "))
					return candidates[1] -- Use first candidate as expected (approximation)
				else
					print("No candidates generated for base: " .. base)
					return nil
				end
			else
				print("Unknown suffix type: " .. type(suffix) .. ", value: " .. vim.inspect(suffix))
				return nil
			end
		end)
		if not success then
			print("Error in expected expansion: " .. result)
			return nil
		end
		return result
	end

	it("expands all abbreviations with suffixes correctly", function()
		local failures = {}
		for base_abbrev, root in pairs(roots) do
			for code, suffix in pairs(suffixes) do
				local derived_abbrev = base_abbrev .. code
				local expanded = abbrev_gen.try_expand(derived_abbrev)
				local expected = safe_expected_expansion(root, suffix)
				print(
					string.format(
						"Expansion: %s -> %s (expected: %s)",
						derived_abbrev,
						expanded or "nil",
						expected or "nil"
					)
				)
				if expanded ~= expected then
					table.insert(
						failures,
						string.format("%s -> %s (expected: %s)", derived_abbrev, expanded or "nil", expected or "nil")
					)
				end
			end
		end
		assert.are.same(0, #failures, "Failures:\n" .. table.concat(failures, "\n"))
	end)

	it("handles capitalized abbreviations", function()
		-- Example with "ab" -> "about" from your pop.txt
		local test_abbrev = "ab"
		local test_suffix_code = "d"
		local capitalized_abbrev = "Ab" .. test_suffix_code -- "Abd"
		local expanded = abbrev_gen.try_expand(capitalized_abbrev)
		print(string.format("Capitalized Expansion: %s -> %s", capitalized_abbrev, expanded or "nil"))
		assert.are.same(
			"Abouted",
			expanded,
			"Should capitalize first letter (note: 'abouted' may not be real word, but tests logic)"
		)
	end)

	it("validates expansions against English dictionary (optional)", function()
		local dict_path = "/usr/share/dict/words"
		local file = io.open(dict_path, "r")
		if not file then
			pending("Dictionary not found; install with 'sudo pacman -S words'")
			return
		end
		local dict = {}
		for line in file:lines() do
			dict[line:lower()] = true
		end
		file:close()

		local missing = {}
		for base_abbrev, root in pairs(roots) do
			for code, suffix in pairs(suffixes) do
				local derived_abbrev = base_abbrev .. code
				local expanded = abbrev_gen.try_expand(derived_abbrev)
				if expanded then
					print(
						string.format(
							"Dictionary check: %s (%s) - %s",
							derived_abbrev,
							expanded,
							dict[expanded:lower()] and "valid" or "missing"
						)
					)
					if not dict[expanded:lower()] then
						table.insert(missing, expanded)
					end
				end
			end
		end
		assert.are.same(0, #missing, "Missing from dictionary:\n" .. table.concat(missing, "\n"))
	end)
end)

local abbrev_gen = require("tipon.core.abbrev-gen") -- Adjust path if needed

describe("abbrev-gen suffix expansions", function()
	local roots = abbrev_gen.roots_by_abbrev
	local suffixes = abbrev_gen.suffix_map

	-- Helper to generate expected expansion (mimic try_expand logic for assertions)
	local function expected_expansion(root, suffix)
		return root:gsub("e$", "") .. suffix -- Simple rule; expand if your logic changes
	end

	it("expands all abbreviations with suffixes correctly", function()
		local failures = {}
		for base_abbrev, root in pairs(roots) do
			for code, suffix in pairs(suffixes) do
				local derived_abbrev = base_abbrev .. code
				local expanded = abbrev_gen.try_expand(derived_abbrev)
				local expected = expected_expansion(root, suffix)
				if expanded ~= expected then
					table.insert(
						failures,
						string.format("%s -> %s (expected: %s)", derived_abbrev, expanded or "nil", expected)
					)
				end
			end
		end
		assert.are.same(0, #failures, "Failures:\n" .. table.concat(failures, "\n"))
	end)

	-- Optional: Test against a dictionary (load a word list)
	it("validates expansions against English dictionary", function()
		local dict_path = "/usr/share/dict/words" -- Or download one
		local dict = {}
		for line in io.lines(dict_path) do
			dict[line:lower()] = true
		end

		local missing = {}
		for base_abbrev, root in pairs(roots) do
			for code, suffix in pairs(suffixes) do
				local derived_abbrev = base_abbrev .. code
				local expanded = abbrev_gen.try_expand(derived_abbrev)
				if expanded and not dict[expanded:lower()] then
					table.insert(missing, expanded)
				end
			end
		end
		assert.are.same(0, #missing, "Missing from dictionary:\n" .. table.concat(missing, "\n"))
	end)
end)

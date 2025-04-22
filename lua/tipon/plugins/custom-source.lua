local abbreviations = {
	j = "person",
	rltp = "relationship",
	-- Add more here
}

return function()
	local custom_source = {
		complete = function(params, callback) -- Removed unused 'self'
			local items = {}
			local word = params.context.cursor_before_line:match("%w+$") or ""

			if vim.bo.filetype == "markdown" then
				for abbr, full in pairs(abbreviations) do
					if word == abbr then
						table.insert(items, {
							label = full,
							insertText = full,
							textEdit = {
								range = {
									start = {
										line = params.context.cursor.row - 1,
										character = params.context.cursor.col - #abbr,
									},
									["end"] = {
										line = params.context.cursor.row - 1,
										character = params.context.cursor.col,
									},
								},
								newText = full,
							},
						})
						break -- Assuming one match per abbreviation for simplicity
					end
				end
			end

			callback(items)
		end,
	}

	return custom_source
end

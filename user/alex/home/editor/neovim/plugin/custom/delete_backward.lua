local function delete_backward()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0));
	local line = vim.api.nvim_get_current_line();
	local start = col;
	-- skip all whitespaces
	while start > 0 and (line:sub(start, start)):match("%s") do
		start = start - 1;
	end;
	if (line:sub(start, start)):match("%w") then
		-- skip all word characters
		while start > 0 and (line:sub(start, start)):match("%w") do
			start = start - 1;
		end;
	else
		-- skip all non-word characters and non-whitespace characters
		while start > 0 and (line:sub(start, start)):match("[^%s%w]") do
			start = start - 1;
		end;
	end;
	local new_line = line:sub(1, start) .. line:sub(col + 1);
	vim.api.nvim_set_current_line(new_line);
	vim.api.nvim_win_set_cursor(0, {
		row,
		start
	});
end;

vim.api.nvim_create_user_command("DeleteBackward", delete_backward, {});

local function quit()
	if #vim.api.nvim_list_bufs() == 1 then
		vim.cmd("w | q | bd")
	else
		vim.cmd("w | bd")
	end
end

vim.api.nvim_create_user_command("Quit", quit, {});

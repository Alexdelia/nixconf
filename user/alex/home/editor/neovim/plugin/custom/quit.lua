local function quit()
	if vim.fn.len(vim.fn.getbufinfo({buflisted = 1})) == 1 then
		vim.cmd("w | q | bd #")
	else
		vim.cmd("w | bp | bd #")
	end
end

vim.api.nvim_create_user_command("Quit", quit, {});

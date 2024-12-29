local function accept_one_word()
	local suggestion = vim.fn['copilot#Accept']("")
	local bar = vim.fn['copilot#TextQueuedForInsertion']()
	return vim.fn.split(bar, [[[ .]\zs]])[1]
end

vim.api.nvim_create_user_command("AcceptOneWord", accept_one_word, {});

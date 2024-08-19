local function open_remote_rev()
	local gitsigns = require("gitsigns")

	local path = vim.fn.expand("%:p")
	local file_relpath = vim.fn.expand("%")

	vim.notify("Opening remote revision for " .. file_relpath .. " - " .. path)
end

vim.api.nvim_create_user_command("OpenRemoteRev", open_remote_rev, {});

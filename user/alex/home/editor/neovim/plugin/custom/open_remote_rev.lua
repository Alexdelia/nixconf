--[[
0000000000000000000000000000000000000000 30 30 1
author Not Committed Yet
author-mail <not.committed.yet>
author-time 1724186940
author-tz +0200
committer Not Committed Yet
committer-mail <not.committed.yet>
committer-time 1724186940
committer-tz +0200
summary Version of user/alex/home/editor/neovim/plugin/custom/open_remote_rev.lua from user/alex/home/editor/neovim/plugin/custom/open_remote_rev.lua
previous d74e0735e9f5530a464c3f045987d1ffe1f47fab user/alex/home/editor/neovim/plugin/custom/open_remote_rev.lua
filename user/alex/home/editor/neovim/plugin/custom/open_remote_rev.lua
]]

local function open_remote_rev()
	local line_num = vim.fn.line('.')
	local status, data = pcall(vim.fn.systemlist, "git blame --porcelain -L " .. line_num .. "," .. line_num .. " " .. vim.fn.expand("%"))
	if not status then
		vim.notify("error getting git blame info", "error")
		return
	end

	print(vim.json.encode(data))

	-- if data starts with "0000000000000000000000000000000000000000" then the line is not committed yet
	if data[1]:match("^0000000000000000000000000000000000000000") then
		vim.notify("no commit", "info")
		return
	end

	local t = {}
	for i, line in ipairs(data) do
		if i == 1 then
			t.rev = line:match("^%S+%s+(%S+)")
		end
		local k, v = line:match("^(%S+)%s+(.*)$")
		if k and v then
			t[k] = v
		end
	end

	print(vim.json.encode(t))
	print(vim.inspect(t))

end

--[[ -- Function to open the current line in the commit that modified it
function OpenModifiedLineInCommit()
  -- Get the commit hash that last modified the current line
  
  -- Get the remote URL
  local remote_url = vim.fn.system('git config --get remote.origin.url')
  remote_url = remote_url:gsub('\n', '')

  -- Construct the URL based on the remote URL format
  if remote_url:match('https://') or remote_url:match('http://') then
    -- HTTPS URL
    remote_url = remote_url:gsub('.git$', '')
  elseif remote_url:match('git@') then
    -- SSH URL (e.g., git@github.com:user/repo.git)
    remote_url = remote_url:gsub('^git@', 'https://')
    remote_url = remote_url:gsub(':', '/')
    remote_url = remote_url:gsub('.git$', '')
  end

  -- Construct the full URL pointing to the commit and the specific line
  local url = string.format('%s/blob/%s/%s#L%s', remote_url, commit_hash, file_relpath, line_num)

  -- Open URL in the default browser
  vim.fn.system({ 'xdg-open', url }) -- Use 'xdg-open' on Linux
  -- vim.fn.system({ 'open', url }) -- Use 'open' on macOS
  -- vim.fn.system({ 'start', url }) -- Use 'start' on Windows
end ]]


vim.api.nvim_create_user_command("OpenRemoteRev", open_remote_rev, {});

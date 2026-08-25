local flavor = {
	github = { commit = "/commit/%s", file = "/blob/%s/%s" },
	gitlab = { commit = "/-/commit/%s", file = "/-/blob/%s/%s" },
	forgejo = { commit = "/commit/%s", file = "/src/commit/%s/%s" },
}

local function git(cmd)
	return (vim.fn.system("git " .. cmd):gsub("%s+$", ""))
end

local function split_remote(url)
	local host, path = url:match("^%a[%w+.-]*://[^@/]*@?([^:/]+):?%d*/(.+)$")
	if not host then
		host, path = url:match("^[^@]+@([^:]+):(.+)$")
	end
	if not host then
		return nil
	end

	return host, (path:gsub("%.git$", ""))
end

local function mapped_forgejo(host)
	local map_file = vim.fn.stdpath("state") .. "/forgejo.json"
	if vim.fn.filereadable(map_file) == 0 then
		return nil
	end

	local ok, map = pcall(vim.fn.json_decode, vim.fn.readfile(map_file))
	if not ok or type(map) ~= "table" then
		return nil
	end

	return map[host]
end

local function resolve_web(remote_url)
	local host, path = split_remote(remote_url)
	if not host then
		return nil
	end

	local forgejo = mapped_forgejo(host) or {}

	local base = git("config --get nvim.webUrl")
	if base == "" then
		base = (forgejo.url or ("https://" .. host)) .. "/" .. path
	end

	local kind = git("config --get nvim.webFlavor")
	if kind == "" then
		kind = forgejo.flavor or (host:match("gitlab") and "gitlab" or "github")
	end

	return (base:gsub("/+$", "")), flavor[kind] or flavor.github
end

local function open_remote_rev()
	local line_num = vim.fn.line(".")
	local status, data = pcall(
		vim.fn.systemlist,
		"git blame --porcelain -L " .. line_num .. "," .. line_num .. " " .. vim.fn.expand("%")
	)
	if not status then
		vim.notify("error getting git blame info", "error")
		return
	end

	local t = {}
	for i, line in ipairs(data) do
		if i == 1 then
			t.rev = line:match("^(%S+)")

			if t.rev:match("^0*$") then
				vim.notify("no commit", "info")
				return
			end
		else
			local k, v = line:match("^(%S+)%s+(.*)$")
			if k and v then
				t[k] = v
			end
		end
	end

	local base, path_of = resolve_web(git("config --get remote.origin.url"))
	if not base then
		vim.notify("could not resolve remote web url", "error")
		return
	end

	local head_rev = git("rev-parse HEAD")
	local head_filename = git("ls-files --full-name -- " .. vim.fn.shellescape(vim.fn.expand("%")))

	local commit_url = base .. path_of.commit:format(t.rev)
	local file_url = base .. path_of.file:format(head_rev, head_filename) .. "#L" .. line_num

	vim.fn.system({ "xdg-open", commit_url })
	vim.fn.system({ "xdg-open", file_url })
end

vim.api.nvim_create_user_command("OpenRemoteRev", open_remote_rev, {})

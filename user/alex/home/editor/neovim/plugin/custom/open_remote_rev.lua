local function open_remote_rev()
    local line_num = vim.fn.line('.')
    local status, data = pcall(vim.fn.systemlist,
                               "git blame --porcelain -L " .. line_num .. "," ..
                                   line_num .. " " .. vim.fn.expand("%"))
    if not status then
        vim.notify("error getting git blame info", "error")
        return
    end

    local t = {}
    for i, line in ipairs(data) do
        if i == 1 then
            t.rev = line:match("^(%S+)")

            if t.rev:match "^0*$" then
                vim.notify("no commit", "info")
                return
            end
        else
            local k, v = line:match("^(%S+)%s+(.*)$")
            if k and v then t[k] = v end
        end
    end

    local remote_url = vim.fn.system('git config --get remote.origin.url'):gsub(
                           '\n', '')
    remote_url = remote_url:gsub('.git$', ''):gsub('^git@', 'https://'):gsub(
                     'com:', 'com/')

    local commit_url = remote_url .. "/commit/" .. t.rev
    local file_url = remote_url .. "/blob/" .. t.rev .. "/" .. t.filename ..
                         "#L" .. line_num

    vim.fn.system({'xdg-open', commit_url})
    vim.fn.system({'xdg-open', file_url})
end

vim.api.nvim_create_user_command("OpenRemoteRev", open_remote_rev, {});

local function quit()
    local open_buffer = vim.fn.len(vim.fn.getbufinfo({buflisted = 1}))

    if open_buffer == 0 then
        vim.cmd("q")
    elseif open_buffer == 1 then
        vim.cmd("w | q | bd #")
    else
        vim.cmd("w | bp | bd #")
    end
end

vim.api.nvim_create_user_command("Quit", quit, {});

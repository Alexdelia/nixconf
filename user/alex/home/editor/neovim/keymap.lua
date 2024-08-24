local opt = {
    noremap = true, -- non-recursive mapping
    silent = true -- do not print the command in the command-line
}

local kmap = vim.api.nvim_set_keymap

-- space as leader key
kmap("", "<Space>", "<Nop>", opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local mapping_by_mode = {
    -- # global keymaps
    [""] = {
        -- ctrl + h / ctrl + l to move between words
        ["<C-h>"] = "b",
        ["<C-l>"] = "w"
    },
    -- # normal mode keymaps
    n = {
        -- shift + h / shift + l to move between buffers
        ["<S-h>"] = ":bp<CR>",
        ["<S-l>"] = ":bn<CR>",

        -- pasting does not yank the replaced text
        --[[
		["p"] = '"_dP',
		["P"] = '"_dP',
		--]]

        ["<leader>f"] = "<cmd>Telescope find_files<CR>",
        ["<leader>s"] = "<cmd>Telescope live_grep<CR>",

        -- ctrl+/ to comment current line
        ["<C-/>"] = ":norm gcc<CR>"
    },
    -- # insert mode keymaps
    i = {
        -- delete whole word with ctrl + backspace / ctrl + delete
        ["<C-BS>"] = "<cmd>DeleteBackward<CR>",
        ["<C-Del>"] = "<C-o>dw",

        -- ctrl+/ to comment current line
        ["<C-/>"] = "<C-o>:norm gcc<CR>"
    },
    -- # visual mode keymaps
    v = {
        -- alt + j / alt + k to move lines up and down
        ["<A-Up>"] = ":m '<-2<CR>gv=gv",
        ["<A-k>"] = ":m '<-2<CR>gv=gv",
        ["<A-Down>"] = ":m '>+1<CR>gv=gv",
        ["<A-j>"] = ":m '>+1<CR>gv=gv",

        -- pasting does not yank the replaced text
        --[[
		["p"] = '"_dP',
		["P"] = '"_dP',
		--]]

        -- inspect
        ["i"] = "<cmd>Inspect<CR>",
        ["<C-i>"] = "<cmd>InspectTree<CR>",

        -- ctrl+/ to comment selected lines
        ["<C-/>"] = ":'<,'>norm gcc<CR>gv=gv"
    },
    -- # visual block mode keymaps
    x = {
        -- alt + j / alt + k to move lines up and down
        ["<A-Up>"] = ":m '<-2<CR>gv=gv",
        ["<A-k>"] = ":m '<-2<CR>gv=gv",
        ["<A-Down>"] = ":m '>+1<CR>gv=gv",
        ["<A-j>"] = ":m '>+1<CR>gv=gv"
    }
}

for mode, mapping in pairs(mapping_by_mode) do
    for k, v in pairs(mapping) do kmap(mode, k, v, opt) end
end

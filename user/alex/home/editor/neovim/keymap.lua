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
		["<C-Left>"] = "b",
		["<C-l>"] = "w",
		["<C-Right>"] = "w",

		-- alt + j / alt + k to move lines up and down
		["<A-Up>"] = ":m '<-2<CR>gv=gv",
		["<A-k>"] = ":m '<-2<CR>gv=gv",
		["<A-Down>"] = ":m '>+1<CR>gv=gv",
		["<A-j>"] = ":m '>+1<CR>gv=gv",

		["<C-m>"] = ":lua vim.diagnostic.goto_next()<CR>",
		["<C-n>"] = ":lua vim.diagnostic.goto_prev()<CR>",

		-- ["<C-CR>"] = ":lua vim.lsp.buf.code_action()<CR>"
		["<C-CR>"] = "<cmd>RunSql<CR>" -- until I I finish to setup lsp for sql
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

		-- save + unload buffers
		["<leader>d"] = "<cmd>Quit<CR>",

		["<leader>f"] = "<cmd>Telescope find_files<CR>",
		["<leader>g"] = "<cmd>Telescope live_grep<CR>",
		["<leader>h"] = ":lua vim.diagnostic.open_float()<CR>",

		["<leader>mh"] = "<cmd>Telescope highlights<CR>",
		["<leader>mi"] = "<cmd>Inspect<CR>",

		-- ctrl+/ to comment current line
		["<C-/>"] = ":norm gcc<CR>",

		["<leader>b"] = "<cmd>Gitsigns blame_line<CR>"
	},
	-- # insert mode keymaps
	i = {
		-- delete whole word with ctrl + backspace / ctrl + delete
		["<C-BS>"] = "<cmd>DeleteBackward<CR>",
		["<C-Del>"] = "<C-o>dw",

		-- ctrl+/ to comment current line
		["<C-/>"] = "<C-o>:norm gcc<CR>",

		-- accept first word of github copilot suggestion
		["<C-y>"] = "<cmd>AcceptOneWord<CR>"
	},
	-- # visual mode keymaps
	v = {
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
	x = {}
}

for mode, mapping in pairs(mapping_by_mode) do
	for k, v in pairs(mapping) do kmap(mode, k, v, opt) end
end

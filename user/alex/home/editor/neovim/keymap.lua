local opt = {
	noremap = true, -- non-recursive mapping
	silent = true, -- do not print the command in the command-line
}

local kmap = vim.api.nvim_set_keymap

--space as leader key
kmap("", "<Space>", "<Nop>", opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local mapping_by_mode = {
	-- # global keymaps
	[""] = {
		-- ctrl + h / ctrl + l to move between words
		["<C-h>"] = "b",
		["<C-l>"] = "w",
	},
	-- # normal mode keymaps
	n = {
		-- shift + h / shift + l to move between buffers
		["<S-h>"] = ":bp<CR>",
		["<S-l>"] = ":bn<CR>",
	},
	-- # visual mode keymaps
	v = {
		-- alt + j / alt + k to move lines up and down
		["<A-j>"] = ":m '>+1<CR>gv=gv",
		["<A-k>"] = ":m '<-2<CR>gv=gv",
	},
}

for mode, mapping in pairs(mapping_by_mode) do
	for k, v in pairs(mapping) do
		kmap(mode, k, v, opt)
	end
end

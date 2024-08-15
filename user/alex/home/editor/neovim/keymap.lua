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
	"" = {
		-- ctrl + h / ctrl + l to move between words
		"<C-h>" = "b",
		"<C-l>" = "w",
	},
}

for mode, mapping in pairs(mapping_by_mode) do
	for k, v in pairs(mapping) do
		kmap(mode, k, v, opt)
	end
end

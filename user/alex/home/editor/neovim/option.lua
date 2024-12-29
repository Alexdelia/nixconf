local opt = {
	clipboard = 'unnamedplus',

	number = true,
	relativenumber = false,

	tabstop = 4,
	shiftwidth = 4,

	mouse = 'a',

	termguicolors = true,

	splitright = true
}

for k, v in pairs(opt) do vim.opt[k] = v end

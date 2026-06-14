require('nvim-treesitter').setup({})

vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('nc_treesitter', { clear = true }),
	callback = function(args)
		local buf = args.buf
		local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)

		if not lang or not vim.treesitter.language.add(lang) then
			return
		end

		vim.treesitter.start(buf, lang)

		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

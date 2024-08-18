require('nvim-treesitter.configs').setup({
    ensure_installed = {},

    auto_install = false,

    highlight = { enable = true },

    indent = { enable = true },

	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
})

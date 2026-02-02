require("flutter-tools").setup({
	lsp = {
		color = {
			enabled = true,
			background = false,
			background_color = nil,
			foreground = false,
			virtual_text = true,
			virtual_text_str = "",
		},
	},

	closing_tags = {
		enabled = true,
		highlight = "LspInlayHint",
		prefix = "/> ",
		-- priority = 10,
	},
})

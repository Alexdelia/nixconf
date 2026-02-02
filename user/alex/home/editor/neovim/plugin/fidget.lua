-- https://github.com/j-hui/fidget.nvim?tab=readme-ov-file#options
require('fidget').setup(
	{
		progress = {
			suppress_on_insert = true,

			ignore = {
				"Github Copilot",
			},

			display = {
				-- TODO: change default style
				progress_style = "WarningMsg", -- in-progress lsp tasks
				group_style = "Title", -- lsp server name
				icon_style = "Question", -- group icon

				overrides = {
					rust_analyzer = { name = "rust-analyzer" },
				},
			},
		},

		-- notification = { window = { avoid = { "NvimTree" } } }
	}
)

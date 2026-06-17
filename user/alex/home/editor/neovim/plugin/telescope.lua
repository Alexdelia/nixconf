local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.load_extension('fzf')
telescope.load_extension('notify')

telescope.setup({
	defaults = {
		vimgrep_arguments = {
			'rg',
			'--color=never',
			'--no-heading',
			'--with-filename',
			'--line-number',
			'--column',
			'--smart-case',
			'--sort=path',
		},

		layout_strategy = 'horizontal',
		prompt_title = false,
		results_title = false,
		preview_title = false,
		borderchars = {
			prompt  = { " ", "│", " ", " ", " ", "│", "│", " " },
			results = { "─", "│", " ", " ", "─", "┤", "│", " " },
			preview = { " ", " ", " ", " ", " ", " ", " ", " " },
		},
		layout_config = {
			horizontal = {
				width = { padding = 0 },
				height = { padding = 0 },
				prompt_position = "top",
				results_width = 0.4,
				preview_width = 0.6,
				preview_cutoff = 1,
			},
		},
		sorting_strategy = 'ascending',

		mappings = {
			i = {
				["<C-Up>"] = actions.cycle_history_prev,
				["<C-Down>"] = actions.cycle_history_next,
			},
			n = {
				["<C-Up>"] = actions.cycle_history_prev,
				["<C-Down>"] = actions.cycle_history_next,
			},
		},

		prompt_prefix = "",
		selection_caret = "",
		entry_prefix = "",
	},

	pickers = {
		live_grep = { prompt_title = false, preview_title = false },
		grep_string = { prompt_title = false, preview_title = false },
		find_files = { prompt_title = false, preview_title = false },
		buffers = { prompt_title = false, preview_title = false },
	},
})

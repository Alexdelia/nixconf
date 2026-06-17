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

		layout_strategy = 'horizontal',

		layout_config = {
			horizontal = {
				width = { padding = 2 },
				height = { padding = 1 },
				prompt_position = "bottom",
				results_width = 0.4,
				preview_width = 0.6,
				preview_cutoff = 1,
			},

			-- bottom_pane = {
			-- height = 8,
			-- preview_cutoff = 1,
			-- prompt_position = "bottom",
			-- width = { padding = 16 },
			-- mirror = false,
			-- },
		},

		sorting_strategy = 'ascending',
	},
})

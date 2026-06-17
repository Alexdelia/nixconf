local bufferline = require('bufferline')

require('bufferline.constants').sep_chars.slope = { "", "" }

local SELECTION = "CursorLine"

local HL = {
	fg = {
		attribute = "fg",
		highlight = "Conceal",
	},
	bg = {
		attribute = "bg",
		highlight = "Normal",
	},
}

local HL_SELECTED = {
	fg = {
		attribute = "fg",
		highlight = "Normal",
	},
	bg = {
		attribute = "bg",
		highlight = SELECTION,
	},
	bold = true,
	italic = false,
}

local HINT_HL = {
	fg = {
		attribute = "fg",
		highlight = "DiagnosticHint",
	},
	sp = {
		attribute = "fg",
		highlight = "DiagnosticHint",
	},
	bg = {
		attribute = "bg",
		highlight = "Normal",
	},
}
local HINT_HL_SELECTED = {
	fg = {
		attribute = "fg",
		highlight = "DiagnosticHint",
	},
	sp = {
		attribute = "fg",
		highlight = "DiagnosticHint",
	},
	bg = {
		attribute = "bg",
		highlight = SELECTION,
	},
	bold = HL_SELECTED.bold,
	italic = HL_SELECTED.italic,
}

local INFO_HL = {
	fg = {
		attribute = "fg",
		highlight = "DiagnosticInfo",
	},
	sp = {
		attribute = "fg",
		highlight = "DiagnosticInfo",
	},
	bg = {
		attribute = "bg",
		highlight = "Normal",
	},
}
local INFO_HL_SELECTED = {
	fg = {
		attribute = "fg",
		highlight = "DiagnosticInfo",
	},
	sp = {
		attribute = "fg",
		highlight = "DiagnosticInfo",
	},
	bg = {
		attribute = "bg",
		highlight = SELECTION,
	},
	bold = HL_SELECTED.bold,
	italic = HL_SELECTED.italic,
}

local WARN_HL = {
	fg = {
		attribute = "fg",
		highlight = "DiagnosticWarn",
	},
	sp = {
		attribute = "fg",
		highlight = "DiagnosticWarn",
	},
	bg = {
		attribute = "bg",
		highlight = "Normal",
	},
}
local WARN_HL_SELECTED = {
	fg = {
		attribute = "fg",
		highlight = "DiagnosticWarn",
	},
	sp = {
		attribute = "fg",
		highlight = "DiagnosticWarn",
	},
	bg = {
		attribute = "bg",
		highlight = SELECTION,
	},
	bold = HL_SELECTED.bold,
	italic = HL_SELECTED.italic,
}

local ERROR_HL = {
	fg = {
		attribute = "fg",
		highlight = "DiagnosticError",
	},
	sp = {
		attribute = "fg",
		highlight = "DiagnosticError",
	},
	bg = {
		attribute = "bg",
		highlight = "Normal",
	},
}
local ERROR_HL_SELECTED = {
	fg = {
		attribute = "fg",
		highlight = "DiagnosticError",
	},
	sp = {
		attribute = "fg",
		highlight = "DiagnosticError",
	},
	bg = {
		attribute = "bg",
		highlight = SELECTION,
	},
	bold = HL_SELECTED.bold,
	italic = HL_SELECTED.italic,
}

local MODIFIED_HL = {
	fg = {
		attribute = "fg",
		highlight = "NvimTreeModifiedFileHL",
	},
	bg = {
		attribute = "bg",
		highlight = "Normal",
	},
}
local MODIFIED_HL_SELECTED = {
	fg = {
		attribute = "fg",
		highlight = "NvimTreeModifiedFileHL",
	},
	bg = {
		attribute = "bg",
		highlight = SELECTION,
	},
	bold = HL_SELECTED.bold,
	italic = HL_SELECTED.italic,
}

bufferline.setup({
	options = {
		mode = "buffers",

		style_preset = bufferline.style_preset.minimal,
		themable = true,
		numbers = "none",

		-- TODO: bubble highlight as indicator
		indicator = {
			style = 'none' -- 'icon' | 'underline' | 'none',
			-- icon = '▎',
		},

		-- max_name_length = 18,
		-- max_prefix_length = 15,
		-- tab_size = 18,

		diagnostics = false,
		diagnostics_update_in_insert = false,
		offsets = {
			{
				filetype = "NvimTree",
				text = "",
				-- text_align = "left" | "center" | "right"
				separator = true
			}
		},

		color_icons = true,
		show_buffer_icons = true,
		show_buffer_close_icons = false,
		show_close_icon = false,
		show_tab_indicators = false,
		show_duplicate_prefix = false,

		separator_style = "slope",

		enforce_regular_tabs = false,
		always_show_bufferline = false,
		auto_toggle_bufferline = true,
		hover = { enabled = false },
		sort_by = 'insert_after_current',
		--[[ sort_by = 'insert_after_current' |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
                -- add custom logic
                return buffer_a.modified > buffer_b.modified
            end
        ]]
	},

	highlights = {
		fill = HL,
		background = HL,

		--[[
			tab
			tab_selected
			tab_separator
			tab_separator_selected
			tab_close
		]] --

		--[[
			close_button
			close_button_visible
			close_button_selected
		]] --

		buffer_visible = HL,
		buffer_selected = HL_SELECTED,

		numbers = HL,
		numbers_visible = HL,
		numbers_selected = HL_SELECTED,

		diagnostic = HL,
		diagnostic_visible = HL,
		diagnostic_selected = HL_SELECTED,
		hint = HINT_HL,
		hint_visible = HINT_HL,
		hint_selected = HINT_HL_SELECTED,
		hint_diagnostic = HINT_HL,
		hint_diagnostic_visible = HINT_HL,
		hint_diagnostic_selected = HINT_HL_SELECTED,
		info = INFO_HL,
		info_visible = INFO_HL,
		info_selected = INFO_HL_SELECTED,
		info_diagnostic = INFO_HL,
		info_diagnostic_visible = INFO_HL,
		info_diagnostic_selected = INFO_HL_SELECTED,
		warning = WARN_HL,
		warning_visible = WARN_HL,
		warning_selected = WARN_HL_SELECTED,
		warning_diagnostic = WARN_HL,
		warning_diagnostic_visible = WARN_HL,
		warning_diagnostic_selected = WARN_HL_SELECTED,
		error = ERROR_HL,
		error_visible = ERROR_HL,
		error_selected = ERROR_HL_SELECTED,
		error_diagnostic = ERROR_HL,
		error_diagnostic_visible = ERROR_HL,
		error_diagnostic_selected = ERROR_HL_SELECTED,

		modified = MODIFIED_HL,
		modified_selected = MODIFIED_HL_SELECTED,
		modified_visible = MODIFIED_HL,

		--[[
			duplicate
			duplicate_visible
			duplicate_selected
		]] --

		separator = {
			fg = HL.bg,
			bg = HL.bg,
		},
		separator_visible = {
			fg = HL.bg,
			bg = HL.bg,
		},
		separator_selected = {
			fg = HL_SELECTED.bg,
			bg = HL.bg,
		},

		--[[
			indicator_visible
			indicator_selected
		]] --

		--[[
			pick
			pick_visible
			pick_selected
		]] --

		offset_separator = {
			fg = {
				attribute = "fg",
				highlight = "WinSeparator",
			},
			bg = {
				attribute = "bg",
				highlight = "Normal",
			},
		},

		trunc_marker = HL,
	},
})

local bufferline = require('bufferline')

bufferline.setup({
	options = {
		mode = "buffers",

		style_preset = bufferline.style_preset.minimal,
		themable = true,
		numbers = "none",

		-- TODO: bubble highlight as indicator
		indicator = {
			style = 'none', -- 'icon' | 'underline' | 'none',
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

		separator_style = "none",

		enforce_regular_tabs = false,
		always_show_bufferline = false,
		auto_toggle_bufferline = true,
		hover = {
			enabled = false,
		},
		--[[ sort_by = 'insert_after_current' |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
                -- add custom logic
                return buffer_a.modified > buffer_b.modified
            end
        ]]
	}
})

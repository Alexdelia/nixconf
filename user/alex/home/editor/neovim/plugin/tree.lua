vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local nvim_tree = require("nvim-tree")

-- `:help nvim-tree.OPTION_NAME`

nvim_tree.setup {
    disable_netrw = true,
    hijack_netrw = true,

    open_on_tab = false,
    hijack_cursor = false,
    update_cwd = true,
    hijack_directories = {
        enable = true,
        auto_open = true,
    },

    diagnostics = {
        enable = false,
        icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
        },
    },
	git = {
		enable = true,
		ignore = true,
		timeout = 500,
	},

    update_focused_file = {
        enable = true,
        update_cwd = true,
        ignore_list = {},
    },

    view = {
        width = 30,
        side = "left",
        number = false,
        relativenumber = false,
    },
	sort = {
		sorter = "case_sensitive",
	},
	filters = {
		dotfiles = true,
		git_ignored = true,
	},

    renderer = {
		group_empty = true,

        highlight_git = true,
        root_folder_modifier = ":t",

        icons = {
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = true,
            },

            glyphs = {
                default = "",
                symlink = "",
                git = {
                    untracked = "",
                    renamed = "",
                    unstaged = "",
                    deleted = "",
                    ignored = "◌",
                    staged = "󰖌",
                    unmerged = "󱓌",
                },
                folder = {
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                },
            }
        }
    }
}

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local nvim_tree = require("nvim-tree")

local function nvim_tree_on_attach(bufnr)
    local api = require("nvim-tree.api")

    local function opts(desc)
        return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true
        }
    end

    api.config.mappings.default_on_attach(bufnr)

    vim.keymap.set('n', '<Right>', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', '<Left>', api.node.navigate.parent_close,
                   opts('Close Folder'))
    vim.keymap.set('n', 'h', api.node.navigate.parent_close,
                   opts('Close Folder'))
end

-- `:help nvim-tree.OPTION_NAME`

nvim_tree.setup {
    on_attach = nvim_tree_on_attach,

    disable_netrw = true,
    hijack_netrw = true,

    open_on_tab = false,
    hijack_cursor = false,
    update_cwd = true,
    hijack_directories = {enable = true, auto_open = true},

    diagnostics = {
        enable = false,
        icons = {hint = "", info = "", warning = "", error = ""}
    },
    git = {enable = true, ignore = true, timeout = 500},

    update_focused_file = {enable = true, update_cwd = true, ignore_list = {}},

    view = {width = 30, side = "left", number = false, relativenumber = false},
    sort = {sorter = "case_sensitive"},
    filters = {dotfiles = false, git_ignored = false},

    renderer = {
        group_empty = true,

        highlight_git = true,
        root_folder_modifier = ":t",

        icons = {
            show = {file = true, folder = true, folder_arrow = true, git = true},

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
                    unmerged = "󱓌"
                },
                folder = {
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = ""
                }
            }
        }
    }
}

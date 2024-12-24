local devicons = require('nvim-web-devicons')

local icons = {
    default = {icon = "", color = "#6d8086", name = "Default"},
    license = {icon = "", color = "#333333", name = "License"},
    lock = {icon = "", color = "#444444", name = "Lock"},
    sh = {icon = "", color = "#ff7043", name = "Shell"},
    rust = {icon = "", color = "#8a3510", name = "Rust"}
}

devicons.setup({
    -- color_icons = true;
    -- default = false;
    strict = true,

    override_by_filename = {LICENSE = icons.license, license = icons.license},
    override_by_extension = {lock = icons.lock, sh = icons.sh, rs = icons.rust}
})

devicons.set_icon({LICENSE = icons.license})

devicons.set_default_icon(icons.default.icon, icons.default.color, 65)

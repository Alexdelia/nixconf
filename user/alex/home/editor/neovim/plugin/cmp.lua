local cmp = require('cmp')
local luasnip = require('luasnip')

luasnip.config.setup {}

local icon = {
	kind = {
		Text = "󰊄",
		Function = "󰊕",
		Variable = "󰫧",
		Value = "󰬺",
		Constant = "󱊈",
		Struct = "󰅩",
		Class = "",
		Interface = "",
		Enum = "󰉺",
		Field = "󰠵",
		Method = "󰫺",
		Property = "󰫽",
		EnumMember = "▴",
		Constructor = "󱩭",
		Module = "",
		Unit = "µ",
		Keyword = "",
		File = "",
		Snippet = "",
		Color = "",
		Reference = "&",
		Folder = "",
		Event = "",
		Operator = "",
		TypeParameter = "T"
	},
	menu = { buffer = "󰪷", path = "", nvim_lsp = "󰫹" }
}

cmp.setup {
	mapping = cmp.mapping.preset.insert {
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete {},
		['<CR>'] = cmp.mapping.confirm { select = true }
		--[[
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
		--]]
	},
	confirm_opts = { behavior = cmp.ConfirmBehavior.Replace, select = false },

	sources = {
		{ name = 'crates' }, {
		name = 'nvim_lsp',
		entry_filter = function(entry, _ctx)
			return cmp.lsp.CompletionItemKind.Snippet ~= entry:get_kind()
		end
	}, { name = 'path' }
		-- { name = 'buffer' },
	},

	formatting = {
		fields = { "menu", "kind", "abbr" },
		format = function(entry, vim_item)
			vim_item.kind = icon.kind[vim_item.kind]
			vim_item.menu = icon.menu[entry.source.name]
			return vim_item
		end
	},
	window = { documentation = cmp.config.window.bordered() },

	snippet = { expand = function(args) luasnip.lsp_expand(args.body) end }
}

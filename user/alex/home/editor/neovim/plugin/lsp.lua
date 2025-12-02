local diagnostic_icon = {
	source = {
		['typos'] = ' ',
		['rust-analyzer'] = ' ',
		['rustc'] = ' ',
	},
	code = {
		['non_upper_case_globals'] = ' ',
	},
}

vim.diagnostic.config({
	underline = true, -- testing

	signs = false, -- https://neovim.io/doc/user/diagnostic.html#diagnostic-signs

	-- https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.Opts.VirtualText
	virtual_text = {
		current_line = nil, -- shows on all lines

		spacing = 4,
		prefix = '',
		suffix = '',

		-- diagnostic has type vim.Diagnostic (which extends `vim.Diagnostic.Set`)
		-- https://neovim.io/doc/user/diagnostic.html#vim.Diagnostic.Set
		format = function(diagnostic)
			local prefix = diagnostic_icon.code[diagnostic.code]
				or diagnostic_icon.source[diagnostic.source]
			-- or (diagnostic.code and '' .. diagnostic.code)
			-- or (diagnostic.source and ' ' .. diagnostic.source)

			if not prefix then
				local code = diagnostic.code and ' ' .. diagnostic.code
				local source = diagnostic.source and ' ' .. diagnostic.source
				prefix = (code and source)
					and string.format("%s %s", source, code)
					or (code or source)
			end

			return prefix
				and string.format("%s %s", prefix, diagnostic.message)
				or diagnostic.message
		end,
	},

	virtual_lines = false, -- diagnostic info as a virtual line under error

	update_in_insert = false, -- diagnostic update in insert mode or on `InsertLeave`

	severity_sort = true,

	float = {
		scope = 'cursor',
		severity_sort = true,

		header = '',
		source = false,
		prefix = '',
		suffix = '',
		format = function(diagnostic)
			local source = diagnostic.source and ('\t ' .. diagnostic.source .. '\n') or ''
			local code = diagnostic.code and ('\t ' .. diagnostic.code .. '\n') or ''

			return string.format(
				"%s%s%s\n",
				source,
				code,
				diagnostic.message
			)
		end,

		border = 'rounded',
	},
})

vim.lsp.inlay_hint.enable(true)

local on_attach = function(_, bufnr)
	local bufmap = function(keys, func)
		vim.keymap.set('n', keys, func, { buffer = bufnr })
	end

	bufmap('<leader>r', vim.lsp.buf.rename)
	bufmap('<leader>a', vim.lsp.buf.code_action)

	bufmap('gd', vim.lsp.buf.definition)
	bufmap('gD', vim.lsp.buf.declaration)
	bufmap('gI', vim.lsp.buf.implementation)
	bufmap('<leader>D', vim.lsp.buf.type_definition)

	local telescope_builtin = require('telescope.builtin')
	bufmap('gr', telescope_builtin.lsp_references)
	bufmap('<leader>s', telescope_builtin.lsp_document_symbols)
	bufmap('<leader>S', telescope_builtin.lsp_dynamic_workspace_symbols)

	bufmap('K', vim.lsp.buf.hover)
	bufmap('<leader>e', function()
		local _, winid = vim.diagnostic.open_float()
		if not winid then
			vim.lsp.buf.hover()
		end
	end)

	vim.api.nvim_buf_create_user_command(
		bufnr,
		'Format',
		function(_) vim.lsp.buf.format() end,
		{}
	)
end

vim.api.nvim_create_augroup('AutoFormat', {})
vim.api.nvim_create_autocmd(
	'BufWritePre',
	{
		pattern = '*.nix,*.lua,*.py,*.dart',
		group = 'AutoFormat',
		callback = function()
			vim.lsp.buf.format({ async = false })
		end,
	}
)

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- disable snippet
-- capabilities.textDocument.completion.completionItem.snippetSupport = false

-- # lua
require('neodev').setup()
vim.lsp.enable("lua_ls")
vim.lsp.config("lua_ls", {
	on_attach = on_attach,
	capabilities = capabilities,

	settings = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = true },
			diagnostics = {
				globals = { 'vim' },
			},
		}
	}
})

-- # nix
vim.lsp.enable("nil_ls")
vim.lsp.config("nil_ls", {
	on_attach = on_attach,
	capabilities = capabilities,

	settings = {
		['nil'] = {
			formatting = { command = { "alejandra" } }
		}
	}
})
vim.lsp.enable("nixd")
vim.lsp.config("nixd", {
	on_attach = on_attach,
	capabilities = capabilities,
})

-- # rust
vim.lsp.enable("rust_analyzer")
vim.lsp.config("rust_analyzer", {
	on_attach = on_attach,
	capabilities = capabilities,

	-- https://rust-analyzer.github.io/book/configuration.html
	settings = {
		['rust-analyzer'] = {
			assist = {
				emitMustUse = true,
			},
			cargo = {
				allFeatures = true, -- possibly deprecated in favor of `features = 'all'`
				features = 'all',
				allTargets = true,
				-- targetDir = true, -- https://rust-analyzer.github.io/book/configuration.html#cargo.targetDir
			},
			imports = {
				granularity = {
					enforce = true,
				},
			},
			-- https://rust-analyzer.github.io/book/configuration.html#inlayHints.bindingModeHints.enable
			inlayHints = {
				closureCaptureHints = {
					enable = true,
				},
				closureReturnTypeHints = {
					enable = true,
				},
				discriminantHints = {
					enable = true,
				},
				expressionAdjustmentHints = {
					enable = "never",
				},
				genericParameterHints = {
					lifetime = {
						enable = false,
					},
					type = {
						enable = true,
					},
				},
				implicitDrops = {
					enable = false,
				},
				lifetimeElisionHints = {
					enable = "never",
				},
				rangeExclusiveHints = {
					enable = true,
				},
			},
			interpret = {
				tests = true,
			},
			-- enabling extra semantic highlighting because I love specialized color information
			semanticHighlighting = {
				operator = {
					specialization = {
						enable = true,
					},
				},
				punctuation = {
					enable = true,
					separate = {
						macro = {
							bang = true,
						},
					},
					specialization = {
						enable = true,
					},
				},
			},
		}
	}
})

-- # c/c++
--[[
vim.lsp.enable("clangd")
vim.lsp.config("clangd", {
	on_attach = on_attach,
	capabilities = capabilities,
})
--]]

-- # python
vim.lsp.enable("ruff")
vim.lsp.config("ruff", {
	on_attach = on_attach,
	capabilities = capabilities,
})
vim.lsp.enable("ty")
vim.lsp.config("ty", {
	on_attach = on_attach,
	capabilities = capabilities,

	settings = {
		ty = {
			inlayHints = {
				variableTypes = true,
				callArgumentNames = true,
			},
		},
	},
})

-- # go
vim.lsp.enable("gopls")
vim.lsp.config("gopls", {
	on_attach = on_attach,
	capabilities = capabilities,

	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				unusedwrite = true,
				useany = true,
			},
			codelenses = {
				generate = true,
				gc_details = true,
				test = true,
			},
			staticcheck = true
		}
	}
})

-- # dart
vim.lsp.enable("dartls")
vim.lsp.config("dartls", {
	on_attach = on_attach,
	capabilities = capabilities,
})

-- # agnostic
vim.lsp.enable("typos_lsp")
vim.lsp.config("typos_lsp", {
	-- cmd_env = { RUST_LOG = "error" },
	init_options = { diagnosticSeverity = "Warning" }
})

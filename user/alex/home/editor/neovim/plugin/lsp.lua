vim.diagnostic.config({ signs = false })
vim.lsp.inlay_hint.enable = true


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
		pattern = '*.nix,*.lua',
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

local lspconfig = require('lspconfig')

-- # lua
require('neodev').setup()
lspconfig.lua_ls.setup {
	on_attach = on_attach,
	capabilities = capabilities,

	root_dir = function() return vim.loop.cwd() end,
	settings = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = true }
		}
	}
}

-- # nix
lspconfig.nil_ls.setup {
	on_attach = on_attach,
	capabilities = capabilities,

	filetypes = { "nix" },
	root_dir = function(fname)
		return lspconfig.util.root_pattern(
			"flake.nix",
			"default.nix",
			"shell.nix",
			".git"
		)(fname) or vim.loop.cwd()
	end,

	settings = {
		['nil'] = {
			formatting = { command = { "alejandra" } }
		}
	}
}
lspconfig.nixd.setup {
	on_attach = on_attach,
	capabilities = capabilities,

	filetypes = { "nix" },
	root_dir = function(fname)
		return lspconfig.util.root_pattern(
			"flake.nix",
			"default.nix",
			"shell.nix",
			".git"
		)(fname) or vim.loop.cwd()
	end
}

-- # rust
lspconfig.rust_analyzer.setup {
	on_attach = on_attach,
	capabilities = capabilities,

	filetypes = { "rust" },
	root_dir = function(fname)
		return lspconfig.util.root_pattern("Cargo.toml", ".git")(fname) or
			vim.loop.cwd()
	end,

	settings = {
		['rust-analyzer'] = {
			assist = {
				emitMustUse = true,
			},
			cargo = {
				allFeatures = true,
				targetDir = true,
			},
			imports = {
				granularity = {
					enforce = true,
				},
				preferNoStd = true,
			},
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
					enable = true,
				},
				genericParameterHints = {
					lifetime = {
						enable = true,
					},
					type = {
						enable = true,
					},
				},
				implicitDrops = {
					enable = true,
				},
				lifetimeElisionHints = {
					enable = true,
				},
				rangeExclusiveHints = {
					enable = true,
				},
			}
		}
	}
}

-- # c/c++
--[[
lspconfig.clangd.setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
--]]

-- # go
lspconfig.gopls.setup {
	on_attach = on_attach,
	capabilities = capabilities,

	filetypes = { "go", "gomod" },
	root_dir = function(fname)
		return lspconfig.util.root_pattern("go.mod", ".git")(fname) or
			vim.loop.cwd()
	end,

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
}

-- # agnostic
lspconfig.typos_lsp.setup {
	-- cmd_env = { RUST_LOG = "error" },
	init_options = { diagnosticSeverity = "Warning" }
}

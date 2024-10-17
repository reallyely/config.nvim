function findInTable(tbl, value)
	for k, v in pairs(tbl) do
		if v == value then
			return k
		end
	end
	return nil
end

return {
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v4.x',
		dependencies = {
			{ 'neovim/nvim-lspconfig' },
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'hrsh7th/nvim-cmp' },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "onsails/lspkind.nvim" },
		},
		config = function()
			local lsp_zero = require('lsp-zero')
			local lspkind = require('lspkind')
			local nvim_lsp = require('lspconfig')

			local cmp = require('cmp')
			local cmp_select = { behavior = cmp.SelectBehavior.Select }
			require('mason').setup({})
			require('mason-lspconfig').setup({
				handlers = {
					function(server_name)
						nvim_lsp[server_name].setup({})
					end,
					ts_ls = function()
						nvim_lsp.ts_ls.setup({
							root_dir = function()
								local root_files = { 'package.json', 'tsconfig.json',
									'jsconfig.json' }
								local paths = vim.fs.find(root_files,
									{ stop = "../" })
								local root_dir = vim.fs.dirname(paths[1])
								return root_dir
							end,
							single_file_support = false,
							on_attach = lsp_zero.on_attach,
						})
					end,
					denols = function()
						nvim_lsp.denols.setup({
							root_dir = nvim_lsp.util.root_pattern("deno.json",
								"deno.jsonc"),
							single_file_support = true,
							on_attach = lsp_zero.on_attach,
						})
					end
				},

			})


			nvim_lsp.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							globals = { 'vim' }
						}
					}
				}
			})

			-- lsp_attach is where you enable features that only work
			-- if there is a language server active in the file
			local lsp_attach = function(client, bufnr)
				local opts = { buffer = bufnr, noremap = true, silent = true }

				vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
				vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
				vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
				vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
				vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
				vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
				vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
				vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
				vim.keymap.set({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end,
					opts)
				vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)

				local function quickfix()
					vim.lsp.buf.code_action({
						filter = function(a) return a.isPreferred end,
						apply = true
					})
				end

				vim.keymap.set('n', '<leader>qf', quickfix, opts)
			end

			lsp_zero.on_attach(lsp_attach)

			cmp.setup({
				preselect = 'item',
				completion = {
					completeopt = 'menu,menuone,noinsert'
				},

				sources = {
					{ name = 'path' },
					{ name = 'nvim_lsp' },
					{ name = 'nvim_lua' },
					{ name = 'buffer',  keyword_length = 3 },
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = 'symbol', -- show only symbol annotations
						maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
						-- can also be a function to dynamically calculate max width such as
						-- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
						ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
						show_labelDetails = true, -- show labelDetails in menu. Disabled by default

						-- The function below will be called before any actual modifications from lspkind
						-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
						before = function(entry, vim_item)
							local details = entry:get_completion_item()
							local source = entry.source.name
							-- If it's from a snippet, we might want to use a different source name
							if source == "luasnip" then
								source = "LuaSnip"
							elseif source == "nvim_lsp" then
								-- For LSP sources, we can try to get the module name
								source = entry.completion_item.detail or '➖'
							end
							vim_item.abbr = string.format('%-30s %s', vim_item.abbr, source)
							return vim_item
						end
					})
				},
				mapping = cmp.mapping.preset.insert({
					['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
					['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
					['<CR>'] = cmp.mapping.confirm({ select = true }),
					['<C-Space>'] = cmp.mapping.complete(),
				}),
			})
		end
	}
}

return {
	"hrsh7th/nvim-cmp",
	version = false, -- last release is way too old
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	dependencies = {
		"VonHeikemen/lsp-zero.nvim",
		"nvim-highlight-colors",
		"onsails/lspkind.nvim",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lua",
		"hrsh7th/cmp-cmdline",
		"saadparwaiz1/cmp_luasnip",
	},
	config = function()
		local cmp = require("cmp")

		local has_words_before = function()
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
		end

		cmp.setup({
			snippet = {
				-- REQUIRED - you must specify a snippet engine
				expand = function(args)
					require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
				end,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			mapping = {
				["<Tab>"] = cmp.mapping(function(fallback)
					if require("luasnip").expand_or_jumpable() then
						require("luasnip").expand_or_jump()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if require("luasnip").jumpable(-1) then
						require("luasnip").jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
				["<C-n>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif has_words_before() then
						cmp.complete()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<C-p>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif has_words_before() then
						cmp.complete()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<C-u>"] = cmp.mapping.scroll_docs(-4),
				["<C-d>"] = cmp.mapping.scroll_docs(4),
				["<C-c>"] = cmp.mapping.abort(),
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = true,
				}),
				["<C-f>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = true,
				}),
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- For luasnip users.
				{ name = "buffer" },
				{ name = "path" },
			}),
			experimental = {
				ghost_text = true,
			},
			formatting = {
				format = function(entry, item)
					local color_item = require("nvim-highlight-colors").format(entry, { kind = item.kind })
					item = require("lspkind").cmp_format({
						-- any lspkind format settings here
					})(entry, item)
					if color_item.abbr_hl_group then
						item.kind_hl_group = color_item.abbr_hl_group
						item.kind = string.format("%s %s", "󰏘", "Color")
					end
					return item
				end,
			},
		})

		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
				{ name = "cmdline" },
				{ name = "buffer" },
			}),
		})

		-- Setup up vim-dadbod
		cmp.setup.filetype({ "sql" }, {
			sources = {
				{ name = "vim-dadbod-completion" },
				{ name = "buffer" },
			},
		})

		require("nvim-autopairs").setup({})
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		-- cmp.event:on("menu_opened", function()
		-- 	vim.b.copilot_suggestion_hidden = true
		-- end)
		--
		-- cmp.event:on("menu_closed", function()
		-- 	vim.b.copilot_suggestion_hidden = false
		-- end)
	end,
}

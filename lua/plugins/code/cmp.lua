return {
	"saghen/blink.cmp",
	version = "1.*",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	dependencies = {
		"rafamadriz/friendly-snippets",
		"nvim-highlight-colors",
	},

	opts = {
		keymap = {
			preset = "none",
			["<Tab>"] = { "snippet_forward", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "fallback" },
			["<C-n>"] = { "select_next", "show", "fallback" },
			["<C-p>"] = { "select_prev", "show", "fallback" },
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },
			["<C-c>"] = { "cancel", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<C-f>"] = { "accept", "fallback" },
		},

		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},

		cmdline = {
			enabled = true,
			keymap = {
				preset = "cmdline",
				["<CR>"] = { "fallback" },
			},
			completion = {
				menu = {
					auto_show = function(ctx)
						return ctx.mode == "cmdline"
							or vim.fn.getcmdtype() == ":"
							or vim.fn.getcmdtype() == "/"
							or vim.fn.getcmdtype() == "?"
					end,
				},
			},
		},

		completion = {
			list = {
				selection = {
					preselect = true,
					auto_insert = true,
				},
			},

			accept = {
				auto_brackets = {
					enabled = true,
				},
			},

			menu = {
				enabled = true,
				auto_show = true,
				border = "rounded",
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
				draw = {
					columns = {
						{ "kind_icon" },
						{ "label", "label_description", gap = 1 },
						{ "kind" },
					},
				},
			},

			documentation = {
				auto_show = true,
				window = {
					border = "rounded",
					winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
				},
			},

			ghost_text = {
				enabled = true,
			},
		},

		signature = {
			enabled = true,
			window = {
				border = "rounded",
			},
		},

		snippets = {
			preset = "luasnip",
		},
	},

	config = function(_, opts)
		local blink = require("blink.cmp")
		blink.setup(opts)
	end,
}

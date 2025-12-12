return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	dependencies = {
		"L3MON4D3/LuaSnip",
		"rafamadriz/friendly-snippets",
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
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},

		cmdline = {
			enabled = true,
			keymap = {
				preset = "cmdline",
				["<CR>"] = { "accept", "fallback" },
				["<C-c>"] = { "cancel", "fallback" },
				["<C-y>"] = { "accept_and_enter" },
			},
			completion = {
				menu = {
					auto_show = function(ctx)
						local line = ctx.line or vim.fn.getcmdline()
						if not line then
							return false
						end
						-- strip leading command chars and whitespace (':', '/', '?')
						line = line:gsub("^[:/?%s]+", "")
						return (
							ctx.mode == "cmdline"
							or vim.fn.getcmdtype() == ":"
							or vim.fn.getcmdtype() == "/"
							or vim.fn.getcmdtype() == "?"
						) and #line >= 3
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
				winhighlight = "Search:None,CursorLine:PmenuSel",
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
		vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#424854" })
		blink.setup(opts)
	end,
}

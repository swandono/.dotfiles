local A = {
	"windwp/nvim-autopairs",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		require("nvim-autopairs").setup({})
	end,
}

local B = { "dstein64/vim-startuptime", event = "VeryLazy", cmd = "StartupTime" }

local C = {
	"folke/persistence.nvim",
	event = "VeryLazy",
	opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" } },
	config = function()
		require("persistence").setup()
		vim.keymap.set(
			"n",
			"<leader>qs",
			require("persistence").load,
			{ noremap = true, silent = true, desc = "Restore Session" }
		)
		vim.keymap.set("n", "<leader>ql", function()
			require("persistence").load({ last = true })
		end, { noremap = true, silent = true, desc = "Restore Last Session" })
		vim.keymap.set(
			"n",
			"<leader>qd",
			require("persistence").stop,
			{ noremap = true, silent = true, desc = "Don't Save Current Session" }
		)
	end,
}

local D = { "nvim-lua/plenary.nvim", event = "VeryLazy" }

local E = {
	"stevearc/dressing.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	init = function()
		---@diagnostic disable-next-line: duplicate-set-field
		vim.ui.select = function(...)
			require("lazy").load({ plugins = { "dressing.nvim" } })
			return vim.ui.select(...)
		end
		---@diagnostic disable-next-line: duplicate-set-field
		vim.ui.input = function(...)
			require("lazy").load({ plugins = { "dressing.nvim" } })
			return vim.ui.input(...)
		end
	end,
	config = function()
		require("dressing").setup({
			input = {
				win_options = {
					winblend = 0,
				},
			},
			builtin = {
				win_options = {
					winblend = 0,
				},
			},
		})
	end,
}

local F = {
	"j-hui/fidget.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		require("fidget").setup({
			notification = {
				window = {
					winblend = 0,
					border = "rounded",
				},
			},
		})
	end,
}

local G = {
	"kristijanhusak/vim-dadbod-ui",
	keys = {
		{ "<leader>db" },
	},
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", lazy = true },
	},
	init = function()
		vim.g.db_ui_use_nerd_fonts = 1
	end,
	config = function()
		vim.keymap.set("n", "<leader>db", "<cmd>DBUIToggle<cr>", { silent = true, noremap = true, desc = "DBUI" })
	end,
}

local js_filetypes = {
	"html",
	"javascript",
	"typescript",
	"javascriptreact",
	"typescriptreact",
	"svelte",
	"vue",
	"tsx",
	"jsx",
	"rescript",
	"xml",
	"php",
	"markdown",
	"astro",
	"glimmer",
	"handlebars",
	"hbs",
}

local H = {
	"windwp/nvim-ts-autotag",
	ft = js_filetypes,
	config = function()
		require("nvim-ts-autotag").setup()
	end,
}

return { A, B, C, D, E, F, G, H }

local A = {
	"windwp/nvim-autopairs",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		require("nvim-autopairs").setup({})
	end,
}
local B = {
	"windwp/nvim-ts-autotag",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		require("nvim-ts-autotag").setup()
	end,
}
local C = { "dstein64/vim-startuptime", event = "VeryLazy", cmd = "StartupTime" }
local D = {
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
local E = { "nvim-lua/plenary.nvim", event = "VeryLazy" }
local F = {
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
local G = {
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
local H = {
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

return { A, B, C, D, E, F, G, H }

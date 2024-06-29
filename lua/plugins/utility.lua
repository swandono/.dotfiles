--  Autopair completion
local A = {
	"windwp/nvim-autopairs",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		require("nvim-autopairs").setup({})
	end,
}

-- Startup Time
local B = { "dstein64/vim-startuptime", cmd = "StartupTime" }

-- Session Management
local C = {
	"folke/persistence.nvim",
	event = {
		"VeryLazy",
	},
	opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" } },
	config = function()
		require("persistence").setup()
		vim.keymap.set(
			"n",
			"<leader>fj",
			require("persistence").load,
			{ noremap = true, silent = true, desc = "Restore Session" }
		)
		vim.keymap.set("n", "<leader>fk", function()
			require("persistence").load({ last = true })
		end, { noremap = true, silent = true, desc = "Restore Last Session" })
		vim.keymap.set(
			"n",
			"<leader>fh",
			require("persistence").stop,
			{ noremap = true, silent = true, desc = "Don't Save Current Session" }
		)
	end,
}

-- Plenary
local D = { "nvim-lua/plenary.nvim" }

-- Dressing
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

-- Fidget to check lsp status
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

-- DBUI
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

-- Autotag for js filetypes
local H = {
	"windwp/nvim-ts-autotag",
	ft = js_filetypes,
	config = function()
		require("nvim-ts-autotag").setup()
	end,
}

-- Inline Colorizer
local I = {
	"NvChad/nvim-colorizer.lua",
	keys = {
		{ "<leader>cc" },
	},
	lazy = true,
	config = function()
		require("colorizer").setup()
		vim.keymap.set(
			"n",
			"<leader>cc",
			"<cmd>ColorizerToggle<cr>",
			{ silent = true, noremap = true, desc = "Toggle Colorizer" }
		)
	end,
}

-- Hide sensitive information
local J = {
	"laytan/cloak.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		require("cloak").setup({
			enabled = true,
			cloak_character = "*",
			highlight_group = "Comment",
			cloak_length = nil,
			try_all_patterns = true,
			patterns = {
				{
					file_pattern = "*.env*",
					cloak_pattern = "=.+",
					replace = nil,
				},
			},
		})
		vim.keymap.set("n", "<leader>ck", "<cmd>CloakToggle<cr>", { desc = "Toggle Cloak" })
	end,
}

-- Zen
local K = {
	"folke/zen-mode.nvim",
	keys = {
		{ "<leader>cz" },
	},
	lazy = true,
	config = function()
		require("zen-mode").setup({
			window = {
				width = 0.70,
				height = 1,
			},
		})
		vim.keymap.set("n", "<leader>cz", "<cmd>ZenMode<cr>", { silent = true, noremap = true, desc = "Zen Mode" })
	end,
}

return { A, B, C, D, E, F, G, H, I, J, K }

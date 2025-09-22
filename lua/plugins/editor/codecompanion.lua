return {
	{
		"olimorris/codecompanion.nvim",
		event = { "BufReadPre", "BufNewFile", "InsertEnter" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
		},
		opts = {
			strategies = {
				chat = { adapter = "copilot", mode = "gpt-5-mini" },
				inline = { adapter = "copilot" },
			},
			display = {
				chat = {
					window = {
						position = "right",
						width = 0.25,
					},
				},
			},
		},
		config = function(_, opts)
			require("codecompanion").setup(opts)
			vim.keymap.set(
				"n",
				"<leader>cc",
				"<cmd>CodeCompanionChat Toggle<cr>",
				{ silent = true, noremap = true, desc = "Code Companion Chat" }
			)
			vim.keymap.set(
				"n",
				"<leader>ca",
				"<cmd>CodeCompanionActions<cr>",
				{ silent = true, noremap = true, desc = "Code Companion Action" }
			)
		end,
	},
}

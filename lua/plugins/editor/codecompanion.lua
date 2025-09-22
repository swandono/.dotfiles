return {
	{
		"olimorris/codecompanion.nvim",
		event = { "BufReadPre", "BufNewFile", "InsertEnter" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"j-hui/fidget.nvim",
			{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
		},
		opts = {
			strategies = {
				-- Use the documented adapter table form to set both name and model
				chat = { adapter = { name = "copilot", model = "gpt-5-mini" } },
				inline = { adapter = { name = "copilot", model = "gpt-5-mini" } },
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
		init = function()
			require("plugins.editor.codecompanion.fidget-spinner"):init()
		end,
		config = function(_, opts)
			print(require("vim.inspect")(opts.adapters or opts))
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

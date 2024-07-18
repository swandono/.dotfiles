return {
	"folke/trouble.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	opts = { use_diagnostic_signs = true },
	config = function(_, opts)
		require("trouble").setup(opts)
		vim.keymap.set(
			"n",
			"<leader>vd",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			{ silent = true, noremap = true, desc = "Document Diagnostics (Trouble)" }
		)
		vim.keymap.set(
			"n",
			"<leader>vw",
			"<cmd>Trouble diagnostics toggle<cr>",
			{ silent = true, noremap = true, desc = "Workspace Diagnostics (Trouble)" }
		)
	end,
}

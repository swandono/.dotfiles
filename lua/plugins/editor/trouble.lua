return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	keys = {
		{
			"<leader>vd",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Document Diagnostics (Trouble)",
		},
		{
			"<leader>vw",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Workspace Diagnostics (Trouble)",
		},
	},
	opts = { use_diagnostic_signs = true },
}

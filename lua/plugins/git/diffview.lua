return {
	"sindrets/diffview.nvim",
	keys = {
		"<leader>dv",
		"<leader>dV",
	},
	config = function()
		require("diffview").setup()
		vim.keymap.set(
			"n",
			"<leader>dv",
			":DiffviewOpen<CR>",
			{ silent = true, noremap = true, desc = "Git Diff Open (Diffview)" }
		)
		vim.keymap.set(
			"n",
			"<leader>dV",
			":DiffviewFileHistory<CR>",
			{ silent = true, noremap = true, desc = "Git Diff Open (Diffview)" }
		)
		vim.keymap.set(
			"n",
			"<leader>dc",
			":DiffviewClose<CR>",
			{ silent = true, noremap = true, desc = "Git Diff Close (Diffview)" }
		)
	end,
}

return {
	"sindrets/diffview.nvim",
	keys = {
		"<leader>go",
		"<leader>gO",
	},
	config = function()
		require("diffview").setup()
		vim.keymap.set(
			"n",
			"<leader>go",
			":DiffviewOpen<CR>",
			{ silent = true, noremap = true, desc = "Git Diff Open (Diffview)" }
		)
		vim.keymap.set(
			"n",
			"<leader>gO",
			":DiffviewFileHistory<CR>",
			{ silent = true, noremap = true, desc = "Git Diff Open (Diffview)" }
		)
		vim.keymap.set(
			"n",
			"<leader>gc",
			":DiffviewClose<CR>",
			{ silent = true, noremap = true, desc = "Git Diff Close (Diffview)" }
		)
	end,
}

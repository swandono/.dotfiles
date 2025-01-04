return {
	"tpope/vim-fugitive",
	keys = { "<leader>gb", "<leader>gi", "<leader>gl" },
	config = function()
		vim.keymap.set("n", "<leader>gi", ":Git ", { desc = "Run Fugitive" })
		vim.keymap.set("n", "<leader>gl", vim.cmd.Git, { desc = "Open Fugitive" })
		vim.keymap.set(
			"n",
			"<leader>gb",
			[[<CMD> Git blame<CR>]],
			{ silent = true, noremap = true, desc = "Git Blame" }
		)
	end,
}

return {
	{
		"supermaven-inc/supermaven-nvim",
		keys = {
			{ "<leader>cV" },
		},
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<C-j>",
					accept_word = "<C-k>",
					clear_suggestion = "<C-o>",
				},
			})
			vim.keymap.set("n", "<leader>cV", "", { desc = "Supermaven Start" })
		end,
	},
}

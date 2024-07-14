return {
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

return {
	"folke/persistence.nvim",
	version = "v2.0.0",
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

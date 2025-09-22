return {
	"folke/persistence.nvim",
	version = "v2.0.0",
	event = {
		"VeryLazy",
	},
	opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" } },
	config = function()
		require("persistence").setup()
		vim.keymap.set("n", "<leader>vj", function()
			require("persistence").load({ last = true })
		end, { noremap = true, silent = true, desc = "Restore Last Session" })
	end,
}

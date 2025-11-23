return {
	"brenoprata10/nvim-highlight-colors",
	cmd = { "HighlightColors" },
	keys = {
		{ "<leader>hc", "<cmd>HighlightColors Toggle<cr>", desc = "Toggle HighlightColors" },
	},
	config = function()
		require("nvim-highlight-colors").setup({
			render = "virtual",
			virtual_symbol = "󱓻",
			enable_tailwind = true,
		})
		vim.cmd("HighlightColors Off")
	end,
}

return {
	"brenoprata10/nvim-highlight-colors",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		require("nvim-highlight-colors").setup({
			render = "virtual",
			virtual_symbol = "󱓻",
			enable_tailwind = true,
		})
		vim.cmd("HighlightColors Off")
		vim.keymap.set(
			"n",
			"<leader>hc",
			"<cmd>HighlightColors Toggle<cr>",
			{ silent = true, noremap = true, desc = "Toggle HighlightColors" }
		)
	end,
}

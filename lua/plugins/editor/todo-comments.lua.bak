return {
	"folke/todo-comments.nvim",
	keys = {
		{ "<leader>tl" },
		{ "<leader>tL" },
		{ "<leader>ts" },
		{ "<leader>tS" },
	},
	config = function()
		require("todo-comments").setup({})
		vim.keymap.set(
			"n",
			"<leader>tl",
			"<cmd>TodoQuickFix<cr>",
			{ silent = true, noremap = true, desc = "Todo (QuickFix)" }
		)
		vim.keymap.set(
			"n",
			"<leader>tL",
			"<cmd>TodoQuickFix keywords=TODO,FIX,FIXME<cr>",
			{ silent = true, noremap = true, desc = "Todo/Fix/Fixme (QuickFix)" }
		)
		vim.keymap.set("n", "<leader>ts", "<cmd>TodoTelescope<cr>", { silent = true, noremap = true, desc = "Todo" })
		vim.keymap.set(
			"n",
			"<leader>tS",
			"<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",
			{ silent = true, noremap = true, desc = "Todo/Fix/Fixme" }
		)
	end,
}

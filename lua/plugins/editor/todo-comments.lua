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
			"<CMD>TodoQuickFix<CR>",
			{ silent = true, noremap = true, desc = "Todo (QuickFix)" }
		)
		vim.keymap.set(
			"n",
			"<leader>tL",
			"<CMD>TodoQuickFix keywords=TODO,FIX,FIXME<CR>",
			{ silent = true, noremap = true, desc = "Todo/Fix/Fixme (QuickFix)" }
		)
		vim.keymap.set("n", "<leader>ts", "<CMD>TodoTelescope<CR>", { silent = true, noremap = true, desc = "Todo" })
		vim.keymap.set(
			"n",
			"<leader>tS",
			"<CMD>TodoTelescope keywords=TODO,FIX,FIXME<CR>",
			{ silent = true, noremap = true, desc = "Todo/Fix/Fixme" }
		)
	end,
}

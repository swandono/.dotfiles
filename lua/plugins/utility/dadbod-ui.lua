return {
	"kristijanhusak/vim-dadbod-ui",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	lazy = true,
	keys = {
		{ "<leader>db" },
	},
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", lazy = true },
	},
	init = function()
		vim.g.db_ui_use_nerd_fonts = 1
	end,
	config = function()
		vim.keymap.set("n", "<leader>db", "<cmd>DBUIToggle<cr>", { silent = true, noremap = true, desc = "DBUI" })
	end,
}

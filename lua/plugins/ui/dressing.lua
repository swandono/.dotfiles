return {
	"stevearc/dressing.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	init = function()
		---@diagnostic disable-next-line: duplicate-set-field
		vim.ui.select = function(...)
			require("lazy").load({ plugins = { "dressing.nvim" } })
			return vim.ui.select(...)
		end
		---@diagnostic disable-next-line: duplicate-set-field
		vim.ui.input = function(...)
			require("lazy").load({ plugins = { "dressing.nvim" } })
			return vim.ui.input(...)
		end
	end,
	config = function()
		require("dressing").setup({
			input = {
				win_options = {
					winblend = 0,
				},
			},
			builtin = {
				win_options = {
					winblend = 0,
				},
			},
		})
	end,
}

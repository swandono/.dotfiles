local A = {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	opts = {
		current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
			delay = 50,
			ignore_whitespace = false,
		},
		update_debounce = 100,
	},
	config = function(_, opts)
		require("gitsigns").setup(opts)
	end,
}
local B = { "tpope/vim-fugitive", event = { "BufReadPre", "BufNewFile" } }
local C = {
	"sindrets/diffview.nvim",
	keys = {
		"<leader>go",
		"<leader>gO",
	},
	config = function()
		require("diffview").setup()
		vim.keymap.set(
			"n",
			"<leader>go",
			":DiffviewOpen<CR>",
			{ silent = true, noremap = true, desc = "Git Diff Open (Diffview)" }
		)
		vim.keymap.set(
			"n",
			"<leader>gO",
			":DiffviewFileHistory<CR>",
			{ silent = true, noremap = true, desc = "Git Diff Open (Diffview)" }
		)
		vim.keymap.set(
			"n",
			"<leader>gc",
			":DiffviewClose<CR>",
			{ silent = true, noremap = true, desc = "Git Diff Close (Diffview)" }
		)
	end,
}

return { A, B, C }

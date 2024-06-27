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
	keys = "<leader>gD",
	config = function()
		require("diffview").setup()
		vim.keymap.set(
			"n",
			"<leader>gD",
			":DiffviewOpen<CR>",
			{ silent = true, noremap = true, desc = "Git Diff (Diffview)" }
		)
	end,
}

return { A, B, C }

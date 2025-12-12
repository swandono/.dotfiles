local function grep_cursor_word(is_cword)
	local tele = require("telescope.builtin")
	local word = vim.fn.expand(is_cword and "<cword>" or "<cWORD>")
	tele.grep_string({ search = word })
end

return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	keys = {
		{ "<leader>ls", function() grep_cursor_word(true) end, desc = "Telescope grep word" },
		{ "<leader>lS", function() grep_cursor_word(false) end, desc = "Telescope grep words" },
		{ "<leader>ks", function() require("telescope.builtin").keymaps() end, desc = "Telescope keymaps" },
		{ "<leader>hs", function() require("telescope.builtin").help_tags() end, desc = "Telescope help tags" },
		{ "<leader>bs", function() require("telescope.builtin").git_branches() end, desc = "Telescope git branches" },
		{ "<leader>gs", function() require("telescope.builtin").git_files() end, desc = "Telescope find git files" },
		{ "<leader>js", function() require("telescope.builtin").lsp_references() end, desc = "Telescope LSP references" },
		{ "<C-j>", function() require("telescope.builtin").buffers() end, desc = "Telescope buffers" },
		{ "<C-k>", function() require("telescope.builtin").find_files() end, desc = "Telescope find files (Git respect)" },
		{ "<C-l>", function() require("telescope.builtin").live_grep() end, desc = "Telescope live grep" },
		{
			"<leader>fs",
			function()
				require("telescope.builtin").find_files({ hidden = true, no_ignore = true, no_ignore_parent = true })
			end,
			desc = "Telescope find all files",
		},
	},
	version = false,
	opts = {
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	},
	dependencies = {
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function(_, opts)
		require("telescope").setup(opts)
		pcall(require("telescope").load_extension, "fzf")
	end,
}

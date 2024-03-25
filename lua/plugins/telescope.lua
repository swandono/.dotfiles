local function setup()
	require("telescope").load_extension("fzf")
	local tele = require("telescope.builtin")
	vim.keymap.set("n", "<leader>ls", function()
		local word = vim.fn.expand("<cword>")
		tele.grep_string({ search = word })
	end, { silent = true, noremap = true, desc = "Telescope grep word" })
	vim.keymap.set("n", "<leader>lS", function()
		local word = vim.fn.expand("<cWORD>")
		tele.grep_string({ search = word })
	end, { silent = true, noremap = true, desc = "Telescope grep words" })
	vim.keymap.set("n", "<leader>js", tele.lsp_document_symbols, { desc = "Telescope LSP document symbols" })
	vim.keymap.set("n", "<leader>ks", tele.keymaps, { desc = "Telescope keymaps" })
	vim.keymap.set("n", "<leader>hs", tele.help_tags, { desc = "Telescope help tags" })
	vim.keymap.set("n", "<leader>bs", tele.git_branches, { desc = "Telescope git branches" })
	vim.keymap.set("n", "<leader>gs", tele.git_files, { desc = "Telescope find git files" })
	vim.keymap.set("n", "<C-j>", tele.buffers, { desc = "Telescope buffers" })
	vim.keymap.set("n", "<C-k>", tele.find_files, { desc = "Telescope find files" })
	vim.keymap.set("n", "<C-l>", tele.live_grep, { desc = "Telescope live grep" })
end

return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	version = false,
	opts = {
		extensions = {
			fzf = {
				fuzzy = true, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			},
		},
	},
	dependencies = { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	config = setup,
	init = function()
		if vim.fn.argc() == 1 then
			local stat = vim.loop.fs_stat(vim.fn.argv(0))
			if stat and stat.type == "directory" then
				setup()
			end
		end
	end,
}

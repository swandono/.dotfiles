return {
	"stevearc/oil.nvim",
	keys = {
		{ "-" },
	},
	init = function()
		vim.g.neo_tree_remove_legacy_commands = 1
		if vim.fn.argc() == 1 then
			local stat = vim.loop.fs_stat(vim.fn.argv(0))
			if stat and stat.type == "directory" then
				require("oil")
			end
		end
	end,
	config = function()
		require("oil").setup({
			default_file_explorer = true,
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name, _)
					return name == ".." or name == ".git"
				end,
			},
		})
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	end,
}

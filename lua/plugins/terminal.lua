return {
	"akinsho/toggleterm.nvim",
	keys = {
		{ "<leader>gk" },
		{ "<c-]>" },
	},
	opts = {
		open_mapping = [[<c-]>]],
		size = 50,
		shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
		start_in_insert = true,
		insert_mappings = true, -- whether or not the open mapping applies in insert mode
		terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
		persist_size = true,
		direction = "vertical",
	},
	config = function(_, opts)
		require("toggleterm").setup(opts)
		local Terminal = require("toggleterm.terminal").Terminal
		local lazygit = Terminal:new({
			cmd = "lazygit",
			hidden = true,
			direction = "float",
		})
		function LazyGitToggle()
			lazygit:toggle()
		end

		vim.api.nvim_set_keymap(
			"n",
			"<leader>gk",
			"<cmd>lua LazyGitToggle()<CR>",
			{ noremap = true, silent = true, desc = "LazyGitToggle" }
		)
	end,
}

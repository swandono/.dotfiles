return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<M-j>", function() require("harpoon"):list():select(1) end, desc = "Harpoon nav file 1" },
		{ "<M-k>", function() require("harpoon"):list():select(2) end, desc = "Harpoon nav file 2" },
		{ "<M-l>", function() require("harpoon"):list():select(3) end, desc = "Harpoon nav file 3" },
		{ "<M-u>", function() require("harpoon"):list():select(4) end, desc = "Harpoon nav file 4" },
		{ "<M-i>", function() require("harpoon"):list():select(5) end, desc = "Harpoon nav file 5" },
		{ "<M-o>", function() require("harpoon"):list():select(6) end, desc = "Harpoon nav file 6" },
		{ "<leader>ma", function() require("harpoon"):list():add() end, desc = "Harpoon mark add file" },
		{
			"<leader>ml",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "Harpoon toggle quick menu",
		},
	},
	config = function()
		require("harpoon"):setup({
			settings = {
				save_on_toggle = true,
			},
		})
	end,
}

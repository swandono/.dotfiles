
return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup({
			settings = {
				save_on_toggle = true,
			},
		})
		vim.keymap.set("n", "<M-j>", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon nav file 1" })
		vim.keymap.set("n", "<M-k>", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon nav file 2" })
		vim.keymap.set("n", "<M-l>", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon nav file 3" })
		vim.keymap.set("n", "<M-u>", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon nav file 4" })
		vim.keymap.set("n", "<M-i>", function()
			harpoon:list():select(5)
		end, { desc = "Harpoon nav file 5" })
		vim.keymap.set("n", "<M-o>", function()
			harpoon:list():select(6)
		end, { desc = "Harpoon nav file 6" })
		vim.keymap.set("n", "<leader>ma", function()
			harpoon:list():add()
		end, { desc = "Harpoon mark add file" })
		vim.keymap.set("n", "<leader>ml", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon toggle quick menu" })
	end,
}

return {
	"folke/trouble.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	opts = { use_diagnostic_signs = true },
	config = function(_, opts)
		require("trouble").setup(opts)
		vim.keymap.set(
			"n",
			"<leader>vd",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			{ silent = true, noremap = true, desc = "Document Diagnostics (Trouble)" }
		)
		vim.keymap.set(
			"n",
			"<leader>vw",
			"<cmd>Trouble diagnostics toggle<cr>",
			{ silent = true, noremap = true, desc = "Workspace Diagnostics (Trouble)" }
		)
		vim.keymap.set("n", "<C-p>", function()
			if require("trouble").is_open() then
				require("trouble").prev({ skip_groups = true, jump = true })
			else
				local ok, _ = pcall(vim.cmd, "cprevious")
				if not ok then
					print("No previous trouble or quickfix item")
				end
			end
			vim.fn.feedkeys("zz<CR>")
		end, { desc = "Previous trouble/quickfix" })
		vim.keymap.set("n", "<C-n>", function()
			if require("trouble").is_open() then
				require("trouble").next({ skip_groups = true, jump = true })
			else
				local ok, _ = pcall(vim.cmd, "cnext")
				if not ok then
					print("No next trouble or quickfix item")
				end
			end
			vim.fn.feedkeys("zz<CR>")
		end, { desc = "Next trouble/quickfix" })
	end,
}

return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"marilari88/neotest-vitest",
			"nvim-neotest/neotest-go",
			"rcasia/neotest-java",
		},
		keys = {
			{ "<leader>to" },
			{ "<leader>ta" },
			{ "<leader>tdd" },
			{ "<leader>tds" },
			{ "<leader>tdo" },
		},
		config = function()
			local neotest = require("neotest")
			neotest.setup({
				adapters = {
					require("neotest-vitest"),
					require("neotest-go"),
					require("neotest-java"),
				},
			})
			vim.keymap.set("n", "<leader>to", function()
				neotest.run.run()
			end, { desc = "Run single function test" })
			vim.keymap.set("n", "<leader>ta", function()
				neotest.run.run(vim.fn.expand("%"))
			end, { desc = "Run file tests" })
			vim.keymap.set("n", "<leader>tdd", function()
				neotest.output_panel.toggle()
				neotest.summary.toggle()
			end, { desc = "Open Neotest Dashboard" })
			vim.keymap.set("n", "<leader>tdo", function()
				neotest.output_panel.toggle()
			end, { desc = "Open Neotest Output Panel" })
			vim.keymap.set("n", "<leader>tds", function()
				neotest.summary.toggle()
			end, { desc = "Open Neotest Summary" })
			vim.keymap.set("n", "<leader>tdc", function()
				neotest.output_panel.clear()
			end, { desc = "Clear Neotest Output Panel" })
		end,
	},
}

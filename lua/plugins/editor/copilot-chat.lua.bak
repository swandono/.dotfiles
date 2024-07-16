return {
	"CopilotC-Nvim/CopilotChat.nvim",
	branch = "canary",
	keys = {
		{ "<leader>ca" },
	},
	dependencies = {
		{ "zbirenbaum/copilot.lua" },
		{ "nvim-lua/plenary.nvim" },
	},
	config = function()
		require("CopilotChat").setup({})
		vim.keymap.set(
			"n",
			"<leader>ca",
			"<CMD>lua require('CopilotChat').toggle()<CR>",
			{ desc = "Open Copilot Chat" }
		)
	end,
	opts = {
		debug = false,
	},
}

return {
	"laytan/cloak.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		require("cloak").setup({
			enabled = true,
			cloak_character = "*",
			highlight_group = "Comment",
			cloak_length = nil,
			try_all_patterns = true,
			patterns = {
				{
					file_pattern = "*.env*",
					cloak_pattern = "=.+",
					replace = nil,
				},
			},
		})
		vim.keymap.set("n", "<leader>ck", "<cmd>CloakToggle<cr>", { desc = "Toggle Cloak" })
	end,
}

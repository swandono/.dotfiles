return {
	"j-hui/fidget.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		require("fidget").setup({
			notification = {
				window = {
					winblend = 0,
					border = "rounded",
                    max_width = 60,
				},
			},
		})
	end,
}

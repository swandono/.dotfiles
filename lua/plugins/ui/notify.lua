return {
	"rcarriga/nvim-notify",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		vim.notify = require("notify")
		vim.notify.setup({
			render = "compact",
			top_down = false,
			background_colour = "#000000",
		})
	end,
}

return {
	"rcarriga/nvim-notify",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		vim.notify = require("notify")
		vim.notify.setup({
			render = "wrapped-compact",
			top_down = false,
			background_colour = "#000000",
			minimum_width = 60,
			max_width = 60,
			fps = 120,
			timeout = 100,
		})
	end,
}

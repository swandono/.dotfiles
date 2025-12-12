return {
	"rcarriga/nvim-notify",
	lazy = true,
	init = function()
		vim.notify = function(...)
			require("lazy").load({ plugins = { "nvim-notify" } })
			return vim.notify(...)
		end
	end,
	config = function()
		local notify = require("notify")
		notify.setup({
			render = "wrapped-compact",
			top_down = false,
			background_colour = "#000000",
			minimum_width = 60,
			max_width = 60,
			fps = 120,
			timeout = 100,
		})
		vim.notify = notify
	end,
}

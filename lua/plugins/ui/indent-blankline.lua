return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	main = "ibl",
	opts = {
		debounce = 100,
		indent = { char = "▏" },
		-- indent = { char = "│" },
		whitespace = { highlight = { "Whitespace", "NonText" } },
		scope = {
			enabled = false,
		},
	},
}

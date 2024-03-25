local function setup()
	require("onedark").setup({
		style = "cool",
		transparent = {
			background = true,
			tabline = true,
			statusline = true,
		},
	})
	require("onedark").load()
end

return {
	{
		"swandono/onedark.nvim",
		event = { "VimEnter", "BufReadPre", "BufNewFile", "InsertEnter" },
		priority = 1000,
		config = setup,
		init = setup,
		opts = { style = "cool" },
	},
}

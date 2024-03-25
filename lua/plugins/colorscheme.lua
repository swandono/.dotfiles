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
		init = function()
			if vim.fn.argc() == 1 then
				setup()
			end
		end,
		opts = { style = "cool" },
	},
}

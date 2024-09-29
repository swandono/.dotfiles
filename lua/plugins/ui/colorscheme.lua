local opts = {
	style = "cool",
	transparent = true,
	lualine = {
		transparent = true,
	},
	colors = {
		bg3 = "#444a61",
		customgrey = "#3c4357",
	},
	highlights = {
		FloatBorder = { fg = "$grey", bg = "$transparent" and "$none" or "$bg0" },
		NormalFloat = { fg = "$fg", bg = "$transparent" and "$none" or "$bg0" },
		IblIndent = { fg = "$customgrey", fmt = "nocombine" },
	},
}

local function setup()
	require("onedark").setup(opts)
	require("onedark").load()
end

return {
	{
		"navarasu/onedark.nvim",
		-- event = { "VimEnter", "BufReadPre", "BufNewFile", "InsertEnter" },
		event = "VeryLazy",
		priority = 1000,
		config = setup,
		init = function()
			if vim.fn.argc() == 1 then
				setup()
			end
		end,
	},
}

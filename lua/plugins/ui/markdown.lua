return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you use standalone mini plugins
	ft = { "markdown", "codecompanion" },
	config = function()
		require("render-markdown").setup({
			heading = {
				position = "inline",
				width = "block",
				left_pad = 1,
				right_pad = 1,
			},
			code = {
				width = "block",
				left_pad = 2,
				right_pad = 2,
			},
			checkbox = {
				unchecked = { icon = "󰄱", highlight = "RenderMarkdownUnchecked" },
				checked = { icon = "", highlight = "RenderMarkdownChecked" },
				custom = {
					todo = { raw = "[>]", rendered = "󰥔", highlight = "RenderMarkdownTodo" },
					fav = { raw = "[~]", rendered = "󰓎", highlight = "RenderMarkdownInfo" },
					warn = { raw = "[!]", rendered = "", highlight = "DiagnosticWarn" },
				},
			},
		})
	end,
}

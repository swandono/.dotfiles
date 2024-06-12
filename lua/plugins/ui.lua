--  Lualine is a statusline
local A = {
	"nvim-lualine/lualine.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	opts = {
		options = {
			icons_enabled = true,
			theme = "auto",
			-- component_separators = { left = "", right = "" },
			-- section_separators = { left = "", right = "" },
			component_separators = { left = "│", right = "│" },
			section_separators = { left = "", right = "" },
			disabled_filetypes = {},
			always_divide_middle = true,
			globalstatus = true,
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { { "filename", path = 1 } },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
	},
}

-- Indent lines
local B = {
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

-- Nvim icons
local C = { "nvim-tree/nvim-web-devicons", lazy = true }

-- Beautify notifications
local D = {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	config = function()
		vim.notify = require("notify")
		vim.notify.setup({
			render = "compact",
			top_down = false,
			background_colour = "#000000",
		})
	end,
}

return { A, B, C, D }

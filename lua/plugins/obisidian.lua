return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	event = {
		"BufReadPre " .. vim.fn.expand("~") .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Swandono/**.md",
		"BufNewFile " .. vim.fn.expand("~") .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Swandono/**.md",
		"BufReadPre " .. vim.fn.expand("~") .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/**.md",
		"BufNewFile " .. vim.fn.expand("~") .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/**.md",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		workspaces = {
			{
				name = "personal",
				path = vim.fn.expand("~") .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Swandono",
			},
			{
				name = "work",
				path = vim.fn.expand("~") .. "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work",
			},
		},
		daily_notes = {
			folder = "Journal",
			date_format = "%Y/%B/%d-%m-%Y",
			default_tags = { "daily-notes" },
			template = nil,
		},
		notes_subdir = "Notes",
		attachments = {
			img_folder = "Files", -- This is the default
		},
	},
}

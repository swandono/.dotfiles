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
		"nvim-treesitter/nvim-treesitter",
		{
			"tadmccorkle/markdown.nvim",
			config = function()
				require("markdown").setup()
				vim.keymap.set("n", "<leader>oo", ":ObsidianToday<CR>", { desc = "Open Today (Obsidian)" })
				vim.keymap.set("n", "<leader>oq", ":ObsidianQuickSwitch<CR>", { desc = "QuickSwitch (Obsidian)" })
				vim.keymap.set("n", "<leader>os", ":ObsidianSearch<CR>", { desc = "Search (Obsidian)" })
				vim.keymap.set("n", "<leader>ob", ":ObsidianBacklinks<CR>", { desc = "Backlinks (Obsidian)" })
				vim.keymap.set("n", "<leader>ot", ":ObsidianTags<CR>", { desc = "Tags (Obsidian)" })
				vim.keymap.set("n", "<leader>o[", ":ObsidianYesterday<CR>", { desc = "Open Yesterday (Obsidian)" })
				vim.keymap.set("n", "<leader>o]", ":ObsidianTomorrow<CR>", { desc = "Open Tomorrow (Obsidian)" })
				vim.keymap.set("n", "<leader>on", ":ObsidianNew ./", { desc = "New Note (Obsidian)" })
				vim.keymap.set(
					"i",
					"<C-o><C-o>",
					"<Cmd>MDListItemBelow<CR>",
					{ desc = "Add List Item Below (Obsidian)" }
				)
				vim.keymap.set("n", "<leader>cm", ":RenderMarkdown toggle<CR>", { desc = "Toggle Render Markdown" })
			end,
		},
		{
			"MeanderingProgrammer/markdown.nvim",
			name = "render-markdown", -- Only needed if you have another plugin named markdown.nvim
			dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you use standalone mini plugins
			-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
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
		},
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
			default_tags = { "journal" },
			template = nil,
		},
		notes_subdir = "Notes",
		new_notes_location = "current_dir",
		attachments = {
			img_folder = "Files", -- This is the default
		},
		ui = {
			enable = false,
		},
	},
}

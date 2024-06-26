-- Trouble
local A = {
	"folke/trouble.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	opts = { use_diagnostic_signs = true },
	config = function(_, opts)
		require("trouble").setup(opts)
		vim.keymap.set(
			"n",
			"<leader>vd",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			{ silent = true, noremap = true, desc = "Document Diagnostics (Trouble)" }
		)
		vim.keymap.set(
			"n",
			"<leader>vw",
			"<cmd>Trouble diagnostics toggle<cr>",
			{ silent = true, noremap = true, desc = "Workspace Diagnostics (Trouble)" }
		)
		vim.keymap.set("n", "<C-p>", function()
			if require("trouble").is_open() then
				require("trouble").prev({ skip_groups = true, jump = true })
			else
				local ok, _ = pcall(vim.cmd, "cprevious")
				if not ok then
					print("No previous trouble or quickfix item")
				end
			end
			vim.fn.feedkeys("zz<CR>")
		end, { desc = "Previous trouble/quickfix" })
		vim.keymap.set("n", "<C-n>", function()
			if require("trouble").is_open() then
				require("trouble").next({ skip_groups = true, jump = true })
			else
				local ok, _ = pcall(vim.cmd, "cnext")
				if not ok then
					print("No next trouble or quickfix item")
				end
			end
			vim.fn.feedkeys("zz<CR>")
		end, { desc = "Next trouble/quickfix" })
	end,
}

-- File Explorer
local B = {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		{ "MunifTanjim/nui.nvim", lazy = true },
	},
	keys = {
		{ "<C-h>" },
	},
	deactivate = function()
		vim.cmd([[Neotree close]])
	end,
	opts = {
		filesystem = {
			bind_to_cwd = false,
			use_libuv_file_watcher = true,
			follow_current_file = {
				enabled = true,
			},
		},
		window = {
			mappings = {
				["<space>"] = "none",
			},
		},
		default_component_configs = {
			indent = {
				with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
				expander_collapsed = "",
				expander_expanded = "",
				expander_highlight = "NeoTreeExpander",
			},
		},
	},
	config = function(_, opts)
		require("neo-tree").setup(opts)
		vim.api.nvim_create_autocmd("TermClose", {
			pattern = "*lazygit",
			callback = function()
				if package.loaded["neo-tree.sources.git_status"] then
					require("neo-tree.sources.git_status").refresh()
				end
			end,
		})
		vim.keymap.set("n", "<C-h>", function()
			require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
		end, { silent = true, noremap = true, desc = "Explorer NeoTree (cwd)" })
	end,
}

-- Search and Replace
local C = {
	"nvim-pack/nvim-spectre",
    -- stylua: ignore
    keys = {
        { "<leader>sp" },
    },
	config = function()
		vim.keymap.set("n", "<leader>sp", function()
			require("spectre").open()
		end, { silent = true, noremap = true, desc = "Replace in files (Spectre)" })
	end,
}

-- Todo Comments
local D = {
	"folke/todo-comments.nvim",
	keys = {
		{ "<leader>tl" },
		{ "<leader>tL" },
		{ "<leader>ts" },
		{ "<leader>tS" },
	},
	config = function()
		require("todo-comments").setup({})
		vim.keymap.set(
			"n",
			"<leader>tl",
			"<cmd>TodoQuickFix<cr>",
			{ silent = true, noremap = true, desc = "Todo (QuickFix)" }
		)
		vim.keymap.set(
			"n",
			"<leader>tL",
			"<cmd>TodoQuickFix keywords=TODO,FIX,FIXME<cr>",
			{ silent = true, noremap = true, desc = "Todo/Fix/Fixme (QuickFix)" }
		)
		vim.keymap.set("n", "<leader>ts", "<cmd>TodoTelescope<cr>", { silent = true, noremap = true, desc = "Todo" })
		vim.keymap.set(
			"n",
			"<leader>tS",
			"<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",
			{ silent = true, noremap = true, desc = "Todo/Fix/Fixme" }
		)
	end,
}

-- Copilot
local E = {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		require("copilot").setup({
			suggestion = {
				enabled = true,
				auto_trigger = false,
				hide_during_completion = true,
				debounce = 75,
			},
			filetypes = {
				["dap-repl"] = false,
			},
		})
		vim.keymap.set("i", "<C-j>", function()
			require("copilot.suggestion").accept()
		end, { expr = true, replace_keycodes = false, desc = "Accept Copilot Suggestion (All)" })
		vim.keymap.set("i", "<C-k>", function()
			require("copilot.suggestion").accept_line()
		end, { expr = true, replace_keycodes = false, desc = "Accept Copilot Suggestion (Line)" })
		vim.keymap.set("i", "<C-l>", function()
			require("copilot.suggestion").next()
		end, { expr = true, replace_keycodes = false, desc = "Cycle Copilot Suggestion" })
		vim.keymap.set("i", "<C-o>", function()
			require("copilot.suggestion").dismiss()
		end, { expr = true, replace_keycodes = false, desc = "Dismiss Copilot Suggestion" })
		vim.keymap.set("n", "<leader>co", function()
			require("copilot.suggestion").toggle_auto_trigger()
		end, { expr = true, replace_keycodes = false, desc = "Toggle Copilot Auto Trigger" })
	end,
}

-- Harpoon (Bookmarks)
local F = {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup({
			settings = {
				save_on_toggle = true,
			},
		})
		vim.keymap.set("n", "<M-j>", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon nav file 1" })
		vim.keymap.set("n", "<M-k>", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon nav file 2" })
		vim.keymap.set("n", "<M-l>", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon nav file 3" })
		vim.keymap.set("n", "<M-u>", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon nav file 4" })
		vim.keymap.set("n", "<M-i>", function()
			harpoon:list():select(5)
		end, { desc = "Harpoon nav file 5" })
		vim.keymap.set("n", "<M-o>", function()
			harpoon:list():select(6)
		end, { desc = "Harpoon nav file 6" })
		vim.keymap.set("n", "<leader>ma", function()
			harpoon:list():add()
		end, { desc = "Harpoon mark add file" })
		vim.keymap.set("n", "<leader>ml", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon toggle quick menu" })
	end,
}

-- OIL (File Explorer)
local G = {
	"stevearc/oil.nvim",
	keys = {
		{ "-" },
	},
	init = function()
		vim.g.neo_tree_remove_legacy_commands = 1
		if vim.fn.argc() == 1 then
			local stat = vim.loop.fs_stat(vim.fn.argv(0))
			if stat and stat.type == "directory" then
				require("oil")
			end
		end
	end,
	config = function()
		require("oil").setup({
			default_file_explorer = true,
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name, _)
					return name == ".." or name == ".git"
				end,
			},
		})
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	end,
}

-- Copilot Chat
local H = {
	"CopilotC-Nvim/CopilotChat.nvim",
	branch = "canary",
	keys = {
		{ "<leader>cm" },
	},
	dependencies = {
		{ "zbirenbaum/copilot.lua" },
		{ "nvim-lua/plenary.nvim" },
	},
	config = function()
		require("CopilotChat").setup({})
		vim.keymap.set(
			"n",
			"<leader>cm",
			"<CMD>lua require('CopilotChat').toggle()<CR>",
			{ desc = "Open Copilot Chat" }
		)
	end,
	opts = {
		debug = false,
	},
}

return { A, B, C, D, E, F, G, H }

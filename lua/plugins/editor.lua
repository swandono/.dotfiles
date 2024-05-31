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
	"github/copilot.vim",
	cmd = "Copilot",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		vim.g.copilot_no_tab_map = true
		vim.b.copilot_enable = true
		vim.g.copilot_filetypes = {
			["dap-repl"] = false,
		}
		vim.keymap.set(
			"i",
			"<C-j>",
			'copilot#Accept("<CR>")',
			{ expr = true, replace_keycodes = false, desc = "Accept Copilot Suggestion" }
		)
		vim.keymap.set("i", "<C-k>", "<Plug>(copilot-accept-word)", { desc = "Accept Copilot Word" })
	end,
}

-- Cloak (Hide sensitive information)
local F = {
	"laytan/cloak.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	config = function()
		require("cloak").setup({
			enabled = true,
			cloak_character = "*",
			highlight_group = "Comment",
			cloak_length = nil,
			try_all_patterns = true,
			patterns = {
				{
					file_pattern = "*.env*",
					cloak_pattern = "=.+",
					replace = nil,
				},
			},
		})
		vim.keymap.set("n", "<leader>ck", "<cmd>CloakToggle<cr>", { desc = "Toggle Cloak" })
	end,
}

-- Harpoon (Bookmarks)
local G = {
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
local H = {
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
		require("oil").setup()
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	end,
}

return { A, B, C, D, E, F, G, H }

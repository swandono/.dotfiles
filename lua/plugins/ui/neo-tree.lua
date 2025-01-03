return {
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
			require("neo-tree.command").execute({ toggle = true, dir = vim.fn.getcwd() })
		end, { silent = true, noremap = true, desc = "Explorer NeoTree (cwd)" })
	end,
}

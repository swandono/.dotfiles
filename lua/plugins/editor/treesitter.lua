return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false, -- nvim-treesitter does not support lazy-loading
		build = ":TSUpdate",
		opts = {
			highlight = {
				enable = true,
				disable = { "dap-repl" },
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<leader>ss",
					node_incremental = "<leader>ss",
					scope_incremental = "<leader>sc",
					node_decremental = "<leader>sd",
				},
			},
			rainbow = {
				enable = true,
				extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
				max_file_lines = nil, -- Do not enable for files with more than n lines, int
			},
			sync_install = false,
			auto_install = true,
			textobjects = {
				move = {
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
				},
				swap = {
					enable = true,
					swap_next = {
						["<leader>s,"] = "@parameter.inner",
					},
					swap_previous = {
						["<leader>s."] = "@parameter.inner",
					},
				},
			},
		},
		config = function(_, opts)
			-- Setup nvim-treesitter (only install_dir option is supported now)
			require("nvim-treesitter").setup(opts)

			-- Enable treesitter highlighting globally via autocmd
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					-- Skip certain filetypes
					local disabled_filetypes = { "dap-repl" }
					if vim.tbl_contains(disabled_filetypes, vim.bo[args.buf].filetype) then
						return
					end
					-- Try to start treesitter highlighting (will fail silently if no parser)
					pcall(vim.treesitter.start, args.buf)
				end,
			})

			-- NOTE: Incremental selection is no longer available in the new nvim-treesitter API.
			-- The following keymaps were previously used for incremental selection:
			-- <leader>ss - init/increment selection
			-- <leader>sc - increment scope
			-- <leader>sd - decrement selection
			-- Consider using nvim-treesitter-textobjects select features instead.
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("treesitter-context").setup({})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				move = {
					set_jumps = true,
				},
			})

			-- Swap keymaps for parameters
			vim.keymap.set("n", "<leader>s,", function()
				require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
			end, { desc = "Swap next parameter" })
			vim.keymap.set("n", "<leader>s.", function()
				require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
			end, { desc = "Swap previous parameter" })
		end,
	},
}

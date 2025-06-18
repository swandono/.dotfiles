return {
	"mfussenegger/nvim-dap",
	dependencies = {
		{ "nvim-neotest/nvim-nio" },
		{
			"rcarriga/nvim-dap-ui",
			opts = {},
			config = function(_, opts)
				local dap = require("dap")
				local dapui = require("dapui")
				dapui.setup(opts)
				dap.listeners.before.event_terminated["dapui_config"] = function()
					dapui.close({})
				end
				dap.listeners.before.event_exited["dapui_config"] = function()
					dapui.close({})
				end
			end,
		},
		{
			"theHamsta/nvim-dap-virtual-text",
			config = function()
				require("nvim-dap-virtual-text").setup()
			end,
			opts = {},
		},
		{
			"jay-babu/mason-nvim-dap.nvim",
			config = function()
				require("mason-nvim-dap").setup()
			end,
			dependencies = "mason.nvim",
			cmd = { "DapInstall", "DapUninstall" },
			opts = {
				automatic_setup = true,
				handlers = {},
				ensure_installed = { "delve" },
			},
		},
		{
			"nvim-telescope/telescope-dap.nvim",
			config = function()
				require("telescope").load_extension("dap")
			end,
			keys = {
				{
					"<leader>dH",
					function()
						require("telescope").extensions.dap.list_breakpoints({})
					end,
					desc = "List Breakpoints",
				},
			},
		},
		{
			"leoluz/nvim-dap-go",
			ft = "go",
			dependencies = "nvim-dap",
			config = function()
				require("dap-go").setup()
			end,
		},
	},
	keys = {
		{ "<leader>dj" },
	},
	config = function()
		-- Monkey-patch both termopen and jobstart to clear modified flag
		local orig_termopen = vim.fn.termopen
		vim.fn.termopen = function(cmd, opts)
			local bufnr = vim.api.nvim_get_current_buf()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_set_option(bufnr, "modified", false)
			end
			return orig_termopen(cmd, opts)
		end
		local orig_jobstart = vim.fn.jobstart
		vim.fn.jobstart = function(cmd, opts)
			local bufnr = vim.api.nvim_get_current_buf()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_set_option(bufnr, "modified", false)
			end
			return orig_jobstart(cmd, opts)
		end

		local dap = require("dap")
		vim.keymap.set(
			"n",
			"<leader>dh",
			dap.toggle_breakpoint,
			{ noremap = true, silent = true, desc = "Toggle Breakpoint (DAP)" }
		)
		vim.keymap.set("n", "<leader>ddh", function()
			require("dapui").float_element("breakpoints")
		end, { noremap = true, silent = true, desc = "Breakpoints Widgets (DAP)" })
		vim.keymap.set(
			"n",
			"<leader>dj",
			dap.continue,
			{ noremap = true, silent = true, desc = "Continue Next Breakpoint or Toggle Options (DAP)" }
		)
		vim.keymap.set(
			"n",
			"<leader>dJ",
			dap.run_to_cursor,
			{ noremap = true, silent = true, desc = "Go to Line (DAP)" }
		)
		vim.keymap.set(
			"n",
			"<leader>dl",
			require("dapui").eval,
			{ noremap = true, silent = true, desc = "Debug Eval (DAP)" }
		)
		vim.keymap.set("n", "<leader>dL", function()
			require("dapui").float_element("scopes")
		end, { noremap = true, silent = true, desc = "Scopes Widgets (DAP)" })
		vim.keymap.set("n", "<leader>di", dap.step_into, { noremap = true, silent = true, desc = "Step Into (DAP)" })
		vim.keymap.set("n", "<leader>dI", dap.step_out, { noremap = true, silent = true, desc = "Step Out (DAP)" })
		vim.keymap.set("n", "<leader>do", dap.step_over, { noremap = true, silent = true, desc = "Step Over (DAP)" })
		vim.keymap.set("n", "<leader>dO", dap.step_back, { noremap = true, silent = true, desc = "Step Back (DAP)" })
		vim.keymap.set(
			"n",
			"<leader>du",
			require("dapui").toggle,
			{ noremap = true, silent = true, desc = "Toggle UI (DAP)" }
		)
		vim.keymap.set("n", "<leader>dk", function()
			require("dapui").float_element("repl", { height = 70, width = 200, position = "center" })
		end, { noremap = true, silent = true, desc = "REPL Widgets (DAP)" })
		vim.keymap.set("n", "<leader>d;", function()
			require("dapui").float_element("watches")
		end, { noremap = true, silent = true, desc = "Watches Widgets (DAP)" })
		vim.keymap.set("n", "<leader>dn", function()
			require("dapui").float_element("console", { height = 70, width = 200, position = "center" })
		end, { noremap = true, silent = true, desc = "Terminal Widgets (DAP)" })
	end,
}

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
					"<leader>ds",
					function()
						require("telescope").extensions.dap.list_breakpoints({})
					end,
					desc = "List Breakpoints",
				},
			},
		},
		-- golang debugger
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
		{ "<leader>dc" },
	},
	config = function()
		local dap = require("dap")
		vim.keymap.set(
			"n",
			"<leader>da",
			dap.toggle_breakpoint,
			{ noremap = true, silent = true, desc = "Toggle Breakpoint (DAP)" }
		)
		vim.keymap.set(
			"n",
			"<leader>dc",
			dap.continue,
			{ noremap = true, silent = true, desc = "Continue Next Breakpoint (DAP)" }
		)
		vim.keymap.set(
			"n",
			"<leader>df",
			dap.run_to_cursor,
			{ noremap = true, silent = true, desc = "Go to Line (DAP)" }
		)
		vim.keymap.set("n", "<leader>di", dap.step_into, { noremap = true, silent = true, desc = "Step Into (DAP)" })
		vim.keymap.set("n", "<leader>dI", dap.step_back, { noremap = true, silent = true, desc = "Step Back (DAP)" })
		vim.keymap.set("n", "<leader>do", dap.step_over, { noremap = true, silent = true, desc = "Step Over (DAP)" })
		vim.keymap.set("n", "<leader>dO", dap.step_out, { noremap = true, silent = true, desc = "Step Out (DAP)" })
		vim.keymap.set(
			"n",
			"<leader>dh",
			require("dap.ui.widgets").hover,
			{ noremap = true, silent = true, desc = "Widgets (DAP)" }
		)
		vim.keymap.set(
			"n",
			"<leader>dd",
			require("dapui").eval,
			{ noremap = true, silent = true, desc = "Debug Eval (DAP)" }
		)
		vim.keymap.set(
			"n",
			"<leader>dt",
			require("dapui").toggle,
			{ noremap = true, silent = true, desc = "Toggle UI (DAP)" }
		)
		vim.keymap.set("n", "<leader>dj", function()
			require("dapui").float_element("breakpoints")
		end, { noremap = true, silent = true, desc = "Breakpoints (DAP)" })
		vim.keymap.set("n", "<leader>dk", function()
			require("dapui").float_element("repl", { height = 62, width = 200, position = "center" })
		end, { noremap = true, silent = true, desc = "REPL (DAP)" })
		vim.keymap.set("n", "<leader>dl", function()
			require("dapui").float_element("console", { height = 62, width = 200, position = "center" })
		end, { noremap = true, silent = true, desc = "Terminal (DAP)" })
	end,
}

return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	build = ":Copilot auth",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	requires = {
		"copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
	},
	config = function()
		require("copilot").setup({
			suggestion = {
				enabled = true,
				auto_trigger = true,
				hide_during_completion = true,
			},
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true,
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
			require("copilot.suggestion").accept_word()
		end, { expr = true, replace_keycodes = false, desc = "Accept Copilot Suggestion (Word)" })
		vim.keymap.set("i", "<C-f>", function()
			require("copilot.suggestion").next()
		end, { expr = true, replace_keycodes = false, desc = "Cycle Copilot Suggestion" })
		vim.keymap.set("i", "<C-o>", function()
			require("copilot.suggestion").dismiss()
		end, { expr = true, replace_keycodes = false, desc = "Dismiss Copilot Suggestion" })
		vim.keymap.set("n", "<leader>cV", function()
			require("copilot.suggestion").toggle_auto_trigger()
		end, { expr = true, replace_keycodes = false, desc = "Toggle Copilot Auto Trigger" })
	end,
}

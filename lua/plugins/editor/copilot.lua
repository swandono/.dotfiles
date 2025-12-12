return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            panel = { enabled = false }, -- less UI = less overhead

			suggestion = {
				enabled = true,
				auto_trigger = true, -- start suggesting as you type
				hide_during_completion = true, -- hide copilot when other completion menu is open
				debounce = 0, -- ↓ default is 75; feel free to try 25–60
				trigger_on_accept = true,
			},

			should_attach = function(_, _)
				if not vim.bo.buflisted then
					return false
				end
				if vim.bo.buftype ~= "" then
					return false
				end
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
				if ok and stats and stats.size and stats.size > 1024 * 1024 then -- >1MB
					return false
				end
				return true
			end,

            filetypes = {
                markdown = true,
                help = true,
                ["dap-repl"] = false,
            },

			server = {
				type = "binary",
				custom_server_filepath = "/opt/homebrew/bin/copilot-language-server",
			},
		})

		-- your keymaps (kept as-is)
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

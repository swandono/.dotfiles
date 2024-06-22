return {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		event = { "BufReadPre", "BufNewFile", "InsertEnter" },
		dependencies = {
			{ "neovim/nvim-lspconfig" }, -- Required
			{
				-- Optional
				"williamboman/mason.nvim",
				build = function()
					pcall(vim.cmd, "MasonUpdate")
				end,
			},
			{ "williamboman/mason-lspconfig.nvim" }, -- Optional
		},
		opts = function()
			local lsp = require("lsp-zero")

			lsp.preset("recommended")

			lsp.ensure_installed({
				"rust_analyzer",
				"gopls",
				"lua_ls",
			})

			-- Fix Undefined global 'vim'
			lsp.nvim_workspace()

			-- Set sign icons
			lsp.set_sign_icons({
				-- error = "E",
				-- warn = "W",
				-- hint = "H",
				-- info = "I",
				error = "✘",
				warn = "▲",
				hint = "⚑",
				info = "»",
			})

			lsp.on_attach(function(_, bufnr)
				vim.keymap.set("i", "<C-h>", function()
					vim.lsp.buf.signature_help()
				end, { buffer = bufnr, remap = false, desc = "Signature help (LSP)" })
				vim.keymap.set("n", "<leader>va", function()
					vim.lsp.buf.code_action()
				end, { buffer = bufnr, remap = false, desc = "Code action (LSP)" })
				vim.keymap.set("n", "<leader>vn", function()
					vim.diagnostic.goto_next()
				end, { buffer = bufnr, remap = false, desc = "Go to next (LSP)" })
				vim.keymap.set("n", "<leader>vp", function()
					vim.diagnostic.goto_prev()
				end, { buffer = bufnr, remap = false, desc = "Go to previous (LSP)" })
				vim.keymap.set("n", "<leader>vr", function()
					vim.lsp.buf.rename()
				end, { buffer = bufnr, remap = false, desc = "Rename (LSP)" })
				vim.keymap.set("n", "<leader>fF", function()
					vim.lsp.buf.format({ async = true })
				end, { buffer = bufnr, remap = false, desc = "Format (LSP)" })
			end)

			lsp.setup()

			vim.diagnostic.config({
				virtual_text = true,
			})
		end,
	},
}

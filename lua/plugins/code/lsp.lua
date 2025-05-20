return {
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile", "InsertEnter" },
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			{ "neovim/nvim-lspconfig" },
		},
		opts = function()
			local lspconfig_defaults = require("lspconfig").util.default_config
			lspconfig_defaults.capabilities = vim.tbl_deep_extend(
				"force",
				lspconfig_defaults.capabilities,
				require("cmp_nvim_lsp").default_capabilities()
			)

			require("mason").setup({})
			require("mason-lspconfig").setup({
				ensure_installed = {
					"rust_analyzer",
					"gopls",
					"vtsls",
					"lua_ls",
				},
				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup({})
					end,
				},
			})

			vim.diagnostic.config({
				virtual_text = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "",
						[vim.diagnostic.severity.WARN] = "⚠",
						[vim.diagnostic.severity.HINT] = "",
						[vim.diagnostic.severity.INFO] = "",
					},
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local bufnr = event.buf
					vim.keymap.set("i", "<C-h>", function()
						vim.lsp.buf.signature_help({ border = "rounded" })
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
					vim.keymap.set(
						"n",
						"K",
						"<cmd>lua vim.lsp.buf.hover({border = 'rounded'})<cr>",
						{ buffer = bufnr, remap = false, desc = "Hover (LSP)" }
					)
					vim.keymap.set(
						"n",
						"gd",
						"<cmd>lua vim.lsp.buf.definition()<cr>",
						{ buffer = bufnr, remap = false, desc = "Definition (LSP)" }
					)
					vim.keymap.set(
						"n",
						"gD",
						"<cmd>lua vim.lsp.buf.declaration()<cr>",
						{ buffer = bufnr, remap = false, desc = "Declaration (LSP)" }
					)
					vim.keymap.set(
						"n",
						"gi",
						"<cmd>lua vim.lsp.buf.implementation()<cr>",
						{ buffer = bufnr, remap = false, desc = "Implementation (LSP)" }
					)
					vim.keymap.set(
						"n",
						"go",
						"<cmd>lua vim.lsp.buf.type_definition()<cr>",
						{ buffer = bufnr, remap = false, desc = "Type definition (LSP)" }
					)
					vim.keymap.set(
						"n",
						"gr",
						"<cmd>lua vim.lsp.buf.references()<cr>",
						{ buffer = bufnr, remap = false, desc = "References (LSP)" }
					)
					vim.keymap.set(
						"n",
						"gs",
						"<cmd>lua vim.lsp.buf.signature_help()<cr>",
						{ buffer = bufnr, remap = false, desc = "Signature help (LSP)" }
					)
					vim.keymap.set(
						"n",
						"<F2>",
						"<cmd>lua vim.lsp.buf.rename()<cr>",
						{ buffer = bufnr, remap = false, desc = "Rename (LSP)" }
					)
					vim.keymap.set(
						"n",
						"<F4>",
						"<cmd>lua vim.lsp.buf.code_action()<cr>",
						{ buffer = bufnr, remap = false, desc = "Code action (LSP)" }
					)
				end,
			})
		end,
	},
}

return {
	"stevearc/conform.nvim",
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>ff",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = "",
			desc = "Format",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "black" },
			java = { "google-java-format" },
			javascript = { { "prettierd", "prettier" } },
			javascriptreact = { { "prettierd", "prettier" } },
			typescript = { { "prettierd", "prettier" } },
			typescriptreact = { { "prettierd", "prettier" } },
			css = { { "prettierd", "prettier" } },
			vue = { { "prettierd", "prettier" } },
			json = { { "prettierd", "prettier" } },
			yaml = { { "prettierd", "prettier" } },
			markdown = { { "prettierd", "prettier" } },
			html = { { "prettierd", "prettier" } },
		},
	},
}

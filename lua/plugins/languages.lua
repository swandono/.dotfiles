local A = {
	"mfussenegger/nvim-jdtls",
	ft = "java",
}

local B = {
	"akinsho/flutter-tools.nvim",
	ft = "dart",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"stevearc/dressing.nvim", -- optional for vim.ui.select
	},
	config = function()
		require("flutter-tools").setup({
			ui = {
				notification_style = "native",
			},
			lsp = {
				color = { -- show the derived colours for dart variables
					enabled = true,
					background = false, -- highlight the background
					background_color = { r = 0, g = 0, b = 0 },
					foreground = true, -- highlight the foreground
					virtual_text = false, -- show the highlight using virtual text
					virtual_text_str = "■", -- the virtual text character to highlight
				},
				on_attach = function(client, bufnr)
					require("config.lsp.handlers").on_attach(client, bufnr)
					vim.cmd("highlight FlutterWidgetGuides ctermfg=9 guifg=grey")
				end,
				settings = {
					renameFilesWithClasses = "always",
					analysisExcludedFolders = {
						".dart",
						".dart-tool",
						".dartServer",
					},
					completeFunctionCalls = true,
					experimentalRefactors = true,
				},
			},
			widget_guides = {
				enabled = true,
			},
			decorations = {
				statusline = {
					project_config = true,
				},
			},
		})
	end,
}

return { A, B }

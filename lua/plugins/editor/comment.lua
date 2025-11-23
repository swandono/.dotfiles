-- Comment
local A = {
	"numToStr/Comment.nvim",
	event = "VeryLazy",
	config = function()
		local ok, integration = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
		require("Comment").setup({
			pre_hook = ok and integration.create_pre_hook() or nil,
		})
	end,
}

-- Comment jsx/tsx
local B = {
	"JoosepAlviste/nvim-ts-context-commentstring",
	ft = { "jsx", "tsx", "javascriptreact", "typescriptreact" },
	config = function()
		require("ts_context_commentstring").setup({ enable_autocmd = false })
	end,
}

return { A, B }

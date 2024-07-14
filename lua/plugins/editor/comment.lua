-- Comment
local A = {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
	dependencies = {},
	lazy = true,
	config = function()
		require("Comment").setup()
	end,
}

-- Comment jsx/tsx
local B = {
	"JoosepAlviste/nvim-ts-context-commentstring",
	ft = { "jsx", "tsx", "javascriptreact", "typescriptreact" },
	config = function()
		require("Comment").setup({
			pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
		})
	end,
}

return { A, B }

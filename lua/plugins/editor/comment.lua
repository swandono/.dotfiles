-- Comment
local A = {
	"numToStr/Comment.nvim",
	event = "VeryLazy",
	config = function()
		local ok, integration = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
		local ts_hook = ok and integration.create_pre_hook() or nil

		require("Comment").setup({
			pre_hook = function(ctx)
				-- 1. jsx/tsx/vue/etc: let ts_context_commentstring decide
				if ts_hook then
					local cstr = ts_hook(ctx)
					if cstr then
						return cstr
					end
				end

				-- 2. If the buffer has a treesitter parser, return nil so Comment.nvim
				--    does its own parse-tree walk (handles embedded languages).
				local has_parser, parser = pcall(vim.treesitter.get_parser, 0)
				if has_parser and parser then
					return nil
				end

				-- 3. No parser: Comment.nvim's own fallback (Comment.ft.calculate) would
				--    crash here -- on Neovim 0.11+ `vim.treesitter.get_parser()` returns
				--    nil instead of raising, and `ft.contains()` indexes it. That error is
				--    then swallowed by U.catch as "[Comment.nvim] nil". So resolve the
				--    commentstring ourselves, which keeps that path unreachable.
				return require("Comment.ft").get(vim.bo.filetype, ctx.ctype) or vim.bo.commentstring
			end,
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

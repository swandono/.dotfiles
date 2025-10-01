require("swandono.set")
require("swandono.remap")
require("swandono.plugin")

local augroup = vim.api.nvim_create_augroup
local Swandono = augroup("Swandono", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

function R(name)
	require("plenary.reload").reload_module(name)
end

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

autocmd({ "BufWritePre" }, {
	group = Swandono,
	pattern = "*",
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, -1, false)
		if not ok or not lines then
			return
		end
		local changed = false
		for i = 1, #lines do
			local new = lines[i]:gsub("%s+$", "")
			if new ~= lines[i] then
				lines[i] = new
				changed = true
			end
		end
		if changed then
			local view = vim.fn.winsaveview()
			pcall(vim.api.nvim_buf_set_lines, bufnr, 0, -1, false, lines)
			vim.fn.winrestview(view)
		end
	end,
})

vim.api.nvim_create_autocmd({
	"BufNewFile",
	"BufRead",
}, {
	pattern = "*.md",
	callback = function()
		vim.opt.conceallevel = 2
	end,
})

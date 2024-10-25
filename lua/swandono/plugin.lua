local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "plugins.code" },
		{ import = "plugins.editor" },
		{ import = "plugins.git" },
		{ import = "plugins.ui" },
		{ import = "plugins.utility" },
	},
	install = { colorscheme = { "onedark" } },
	checker = { enabled = false },
	-- rocks = {
	-- 	hererocks = false,
	-- 	enabled = false,
	-- },
})

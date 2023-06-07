vim.opt.exrc = true
vim.opt.guicursor = ""
vim.opt.relativenumber = true
vim.opt.hlsearch = false
vim.opt.hidden = true
vim.opt.errorbells = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.nu = true
vim.opt.wrap = false
vim.opt.smartcase = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.showmode = false
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.signcolumn = "yes"
vim.opt.encoding = "UTF-8"
vim.opt.colorcolumn = "80"

vim.opt.cmdheight = 1
vim.opt.updatetime = 50
vim.opt.wildmode = "longest,list,full"
vim.opt.wildmenu = true

vim.g.copilot_assume_mapped = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.opt.encoding = "UTF-8"
vim.opt.updatetime = 50
vim.opt.termguicolors = true
vim.opt.guicursor = ""
vim.opt.cursorline = true
vim.opt.showmode = false
vim.opt.mouse = ""

vim.opt.exrc = true
vim.opt.errorbells = false

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.hidden = true
vim.opt.swapfile = false

vim.opt.scrolloff = 8
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.foldenable = true
vim.opt.wrap = false
vim.opt.breakindent = true

vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.cmdheight = 1
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.wildmode = "longest,list,full"
vim.opt.wildmenu = true

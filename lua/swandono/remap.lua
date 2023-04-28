vim.g.mapleader = " "
vim.keymap.set("n", "<leader>fs", vim.cmd.Ex)
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<Leader><CR>", ":so<cr>")
vim.keymap.set("n", "<leader>0", ":edit<CR>")
vim.keymap.set("n", "<leader>1", ":set nowrap!<CR>")
vim.keymap.set("n", "<leader>2", "zR:IndentBlanklineEnable<CR>")
vim.keymap.set("n", "<leader>3", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>4", ":IndentBlanklineEnable<CR>")
vim.keymap.set("n", "<leader>5", ":silent !chmod +x %<CR>")
vim.keymap.set("n", "<leader>9", ":LspRestart<CR>")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "n", "nzzzv")

vim.keymap.set("n", "<leader>y", '"*y')
vim.keymap.set("v", "<leader>y", '"*y')
vim.keymap.set("x", "<leader>p", '"_dP')
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

vim.keymap.set("n", "<leader>u", [[<CMD>UndotreeShow<CR>]])

vim.keymap.set("n", "<leader>bd", [[<CMD>bd<CR>]])
vim.keymap.set("n", "<leader>oo", [[<CMD>only<CR>]])
vim.keymap.set("n", "<leader>b[[", [[<CMD>BufferLineCloseLeft<CR>]])
vim.keymap.set("n", "<leader>b]]", [[<CMD>BufferLineCloseRight<CR>]])
vim.keymap.set("n", "<leader>be", [[<CMD>BufferLineSortByExtension<CR>]])
vim.keymap.set("n", "<leader>bf", [[<CMD>BufferLineSortByDirectory<CR>]])
vim.keymap.set("n", "<leader>bn", [[<CMD>BufferLineCycleNext<CR>]])
vim.keymap.set("n", "<leader>bp", [[<CMD>BufferLineCyclePrev<CR>]])
vim.keymap.set("n", "<leader>bh", [[<CMD>split<CR>]])
vim.keymap.set("n", "<leader>bv", [[<CMD>vsplit<CR>]])
vim.keymap.set("n", "<leader>ws[", [[<CMD>vertical resize -5<CR>]])
vim.keymap.set("n", "<leader>ws]", [[<CMD>vertical resize +5<CR>]])
vim.keymap.set("n", "<leader>ws;", [[<CMD>resize -5<CR>]])
vim.keymap.set("n", "<leader>ws'", [[<CMD>resize +5<CR>]])

vim.keymap.set("n", "<leader>gd", vim.cmd.Gdif)
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>gj", [[<CMD> Neogit kind=replace<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>gn", [[<CMD> Gitsigns next_hunk<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>gp", [[<CMD> Gitsigns prev_hunk<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>grb", [[<CMD> Gitsigns reset_buffer<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>grh", [[<CMD> Gitsigns reset_hunk<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>gi", [[<CMD> Gitsigns toggle_current_line_blame<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>go", [[<CMD> Gitsigns toggle_signs<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>gm", [[<CMD> Gitsigns toggle_deleted<CR>]], { silent = true, noremap = true })

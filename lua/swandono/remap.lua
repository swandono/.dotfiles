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



vim.g.mapleader = " "
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<leader><CR>", ":edit<CR>")
vim.keymap.set("n", "<leader>0", ":LspRestart<CR>")
vim.keymap.set("n", "<leader>1", ":set nowrap!<CR>")
vim.keymap.set("n", "<leader>2", "zR:IndentBlanklineEnable<CR>")
vim.keymap.set("n", "<leader>3", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>4", ":delm! | delm A-Z0-9<CR>")
vim.keymap.set("n", "<leader>5", ":silent !chmod +x %<CR>")
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
vim.keymap.set("n", "<leader>bh", [[<CMD>split<CR>]])
vim.keymap.set("n", "<leader>bv", [[<CMD>vsplit<CR>]])
vim.keymap.set("n", "<leader>ws[", [[<CMD>vertical resize -5<CR>]])
vim.keymap.set("n", "<leader>ws]", [[<CMD>vertical resize +5<CR>]])
vim.keymap.set("n", "<leader>ws;", [[<CMD>resize -5<CR>]])
vim.keymap.set("n", "<leader>ws'", [[<CMD>resize +5<CR>]])

vim.keymap.set("n", "<leader>co", ":copen<CR>")
vim.keymap.set("n", "<leader>cc", ":cclose<CR>")
vim.keymap.set("n", "<leader>cn", ":cnext<CR>")
vim.keymap.set("n", "<leader>cp", ":cprevious<CR>")

vim.keymap.set("n", "<leader>fn", [[:TSTextobjectGotoNextStart @function.outer<CR>zz]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>sn", [[:TSTextobjectGotoNextStart @class.outer<CR>zz]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>fp", [[:TSTextobjectGotoPreviousStart @function.outer<CR>zz]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>sp", [[:TSTextobjectGotoPreviousStart @class.outer<CR>zz]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>fN", [[:TSTextobjectGotoNextEnd @function.outer<CR>zz]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>sN", [[:TSTextobjectGotoNextEnd @class.outer<CR>zz]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>fP", [[:TSTextobjectGotoPreviousEnd @function.outer<CR>zz]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>sP", [[:TSTextobjectGotoPreviousEnd @class.outer<CR>zz]], { silent = true, noremap = true })

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>gb", [[<CMD> Git blame<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>gj", [[<CMD> Neogit kind=replace<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>gn", [[<CMD> Gitsigns next_hunk<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>gp", [[<CMD> Gitsigns prev_hunk<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>grb", [[<CMD> Gitsigns reset_buffer<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>grh", [[<CMD> Gitsigns reset_hunk<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>gi", [[<CMD> Gitsigns toggle_current_line_blame<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>go", [[<CMD> Gitsigns toggle_signs<CR>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader>gm", [[<CMD> Gitsigns toggle_deleted<CR>]], { silent = true, noremap = true })

vim.keymap.set("n", "<leader>cf", ":e %:p:h/")

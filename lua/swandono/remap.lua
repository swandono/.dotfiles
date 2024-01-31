vim.g.mapleader = " "
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })
vim.keymap.set("n", "<leader><CR>", ":edit<CR>", { desc = "Edit" })
vim.keymap.set("n", "<leader>0", ":LspRestart<CR>", { desc = "LspRestart" })
vim.keymap.set("n", "<leader>1", ":set nowrap!<CR>", { desc = "Toggle Wrap" })
vim.keymap.set("n", "<leader>2", ":Sex<CR>", { desc = "Open File Explorer" })
vim.keymap.set("n", "<leader>3", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace Word" })
vim.keymap.set("n", "<leader>4", ":delm! | delm A-Z0-9<CR>", { desc = "Delete Marks" })
vim.keymap.set("n", "<leader>5", ":silent !chmod +x %<CR>", { desc = "Chmod +x" })
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "n", "nzzzv")

vim.keymap.set("n", "<leader>y", '"*y', { desc = "Copy to Clipboard" })
vim.keymap.set("v", "<leader>y", '"*y', { desc = "Copy to Clipboard" })
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste from Clipboard" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Line Up" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Line Down" })

vim.keymap.set("n", "<leader>u", [[<CMD>UndotreeShow<CR>]], { desc = "Open UndoTree" })

vim.keymap.set("n", "<leader>bd", [[<CMD>bd<CR>]], { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bo", [[<CMD>only<CR>]], { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bh", [[<CMD>split<CR>]], { desc = "Split Buffer" })
vim.keymap.set("n", "<leader>bv", [[<CMD>vsplit<CR>]], { desc = "VSplit Buffer" })

vim.keymap.set("n", "<leader>co", ":copen<CR>", { desc = "Open Quickfix" })
vim.keymap.set("n", "<leader>cc", ":cclose<CR>", { desc = "Close Quickfix" })

vim.keymap.set("n", "<leader>fn", [[:TSTextobjectGotoNextStart @function.outer<CR>zz]],
    { silent = true, noremap = true, desc = "Next Function" })
vim.keymap.set("n", "<leader>cvn", [[:TSTextobjectGotoNextStart @class.outer<CR>zz]],
    { silent = true, noremap = true, desc = "Next Class" })
vim.keymap.set("n", "<leader>fp", [[:TSTextobjectGotoPreviousStart @function.outer<CR>zz]],
    { silent = true, noremap = true, desc = "Previous Function" })
vim.keymap.set("n", "<leader>cvp", [[:TSTextobjectGotoPreviousStart @class.outer<CR>zz]],
    { silent = true, noremap = true, desc = "Previous Class" })
vim.keymap.set("n", "<leader>fN", [[:TSTextobjectGotoNextEnd @function.outer<CR>zz]],
    { silent = true, noremap = true, desc = "Next Function" })
vim.keymap.set("n", "<leader>cvN", [[:TSTextobjectGotoNextEnd @class.outer<CR>zz]],
    { silent = true, noremap = true, desc = "Next Class" })
vim.keymap.set("n", "<leader>fP", [[:TSTextobjectGotoPreviousEnd @function.outer<CR>zz]],
    { silent = true, noremap = true, desc = "Previous Function" })
vim.keymap.set("n", "<leader>cvP", [[:TSTextobjectGotoPreviousEnd @class.outer<CR>zz]],
    { silent = true, noremap = true, desc = "Previous Class" })

vim.keymap.set("n", "<leader>gs", ":Git ", { desc = "Run Fugitive" })
vim.keymap.set("n", "<leader>gj", vim.cmd.Git, { desc = "Open Fugitive" })
vim.keymap.set("n", "<leader>gb", [[<CMD> Git blame<CR>]], { silent = true, noremap = true, desc = "Git Blame" })
vim.keymap.set("n", "<leader>gn", [[<CMD> Gitsigns next_hunk<CR>]],
    { silent = true, noremap = true, desc = "Next Hunk" })
vim.keymap.set("n", "<leader>gp", [[<CMD> Gitsigns prev_hunk<CR>]],
    { silent = true, noremap = true, desc = "Previous Hunk" })
vim.keymap.set("n", "<leader>grb", [[<CMD> Gitsigns reset_buffer<CR>]],
    { silent = true, noremap = true, desc = "Reset Buffer" })
vim.keymap.set("n", "<leader>grh", [[<CMD> Gitsigns reset_hunk<CR>]],
    { silent = true, noremap = true, desc = "Reset Hunk" })
vim.keymap.set("n", "<leader>gh", [[<CMD> Gitsigns preview_hunk<CR>]],
    { silent = true, noremap = true, desc = "Preview Hunk" })
vim.keymap.set("n", "<leader>gd", [[<CMD> Gitsigns toggle_deleted<CR>]],
    { silent = true, noremap = true, desc = "Toggle Deleted" })

vim.keymap.set("n", "<leader>cf", ":e %:p:h/", { desc = "Open File" })
vim.keymap.set("n", "<leader>t2", ":set tabstop=2 shiftwidth=2 softtabstop=2<CR>", { desc = "Set Tabstop 2" })
vim.keymap.set("n", "<leader>t4", ":set tabstop=4 shiftwidth=4 softtabstop=4<CR>", { desc = "Set Tabstop 4" })

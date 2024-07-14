vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape" })

vim.keymap.set("n", "<leader>lz", ":Lazy<CR>", { desc = "Open Lazy" })
vim.keymap.set("n", "<leader>ms", ":Mason<CR>", { desc = "Open Mason" })
vim.keymap.set("n", "<leader>ch", ":checkhealth<CR>", { desc = "Check Health" })
vim.keymap.set("n", "<leader>rl", ":LspRestart<CR>", { desc = "Restart LSP" })
vim.keymap.set("n", "<leader>li", ":LspInfo<CR>", { desc = "LSP Info" })
vim.keymap.set("n", "<leader>tw", ":set nowrap!<CR>", { desc = "Toggle Wrap" })
vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace Word" })
vim.keymap.set("n", "<leader>rm", ":delm! | delm A-Z0-9<CR>", { desc = "Remove Marks" })
vim.keymap.set("n", "<leader>0", ":silent !chmod +x %<CR>", { desc = "Chmod +x" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })
vim.keymap.set("n", "<leader><CR>", ":edit<CR>", { desc = "Edit" })
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "n", "nzzzv")

vim.keymap.set("n", "<leader>y", [["*Y]], { desc = "Copy Line to Clipboard" })
vim.keymap.set("v", "<leader>y", [["*y]], { desc = "Copy to Clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from Clipboard (below)" })
vim.keymap.set({ "n", "v" }, "<leader>P", [["+P]], { desc = "Paste from Clipboard (above)" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Line Up" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Line Down" })

vim.keymap.set("n", "<leader>u", [[<CMD>UndotreeShow<CR>]], { desc = "Open UndoTree" })

vim.keymap.set("n", "<leader>bd", [[<CMD>bd<CR>]], { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bo", [[<CMD>only<CR>]], { desc = "Buffer Only" })
vim.keymap.set("n", "<leader>bh", [[<CMD>split<CR>]], { desc = "Split Buffer" })
vim.keymap.set("n", "<leader>bv", [[<CMD>vsplit<CR>]], { desc = "VSplit Buffer" })

vim.keymap.set({ "n", "v" }, "<Up>", [[<CMD>resize -2<CR>]], { desc = "Resize Up" })
vim.keymap.set({ "n", "v" }, "<Down>", [[<CMD>resize +2<CR>]], { desc = "Resize Down" })
vim.keymap.set({ "n", "v" }, "<Left>", [[<CMD>vertical resize -2<CR>]], { desc = "Resize Left" })
vim.keymap.set({ "n", "v" }, "<Right>", [[<CMD>vertical resize +2<CR>]], { desc = "Resize Right" })

vim.keymap.set(
	"n",
	"<leader>fn",
	[[:TSTextobjectGotoNextStart @function.outer<CR>zz]],
	{ silent = true, noremap = true, desc = "Next Function" }
)
vim.keymap.set(
	"n",
	"<leader>cn",
	[[:TSTextobjectGotoNextStart @class.outer<CR>zz]],
	{ silent = true, noremap = true, desc = "Next Class" }
)
vim.keymap.set(
	"n",
	"<leader>fp",
	[[:TSTextobjectGotoPreviousStart @function.outer<CR>zz]],
	{ silent = true, noremap = true, desc = "Previous Function" }
)
vim.keymap.set(
	"n",
	"<leader>cp",
	[[:TSTextobjectGotoPreviousStart @class.outer<CR>zz]],
	{ silent = true, noremap = true, desc = "Previous Class" }
)
vim.keymap.set(
	"n",
	"<leader>fN",
	[[:TSTextobjectGotoNextEnd @function.outer<CR>zz]],
	{ silent = true, noremap = true, desc = "Next Function" }
)
vim.keymap.set(
	"n",
	"<leader>cN",
	[[:TSTextobjectGotoNextEnd @class.outer<CR>zz]],
	{ silent = true, noremap = true, desc = "Next Class" }
)
vim.keymap.set(
	"n",
	"<leader>fP",
	[[:TSTextobjectGotoPreviousEnd @function.outer<CR>zz]],
	{ silent = true, noremap = true, desc = "Previous Function" }
)
vim.keymap.set(
	"n",
	"<leader>cP",
	[[:TSTextobjectGotoPreviousEnd @class.outer<CR>zz]],
	{ silent = true, noremap = true, desc = "Previous Class" }
)

vim.keymap.set("n", "<leader>gi", ":Git ", { desc = "Run Fugitive" })
vim.keymap.set("n", "<leader>gl", vim.cmd.Git, { desc = "Open Fugitive" })
vim.keymap.set("n", "<leader>gb", [[<CMD> Git blame<CR>]], { silent = true, noremap = true, desc = "Git Blame" })
vim.keymap.set(
	"n",
	"<leader>gn",
	[[<CMD> Gitsigns next_hunk<CR>]],
	{ silent = true, noremap = true, desc = "Next Hunk (Gitsigns)" }
)
vim.keymap.set(
	"n",
	"<leader>gp",
	[[<CMD> Gitsigns prev_hunk<CR>]],
	{ silent = true, noremap = true, desc = "Previous Hunk (Gitsigns)" }
)
vim.keymap.set(
	"n",
	"<leader>gab",
	[[<CMD> Gitsigns stage_buffer<CR>]],
	{ silent = true, noremap = true, desc = "Stage Buffer (Gitsigns)" }
)
vim.keymap.set(
	"n",
	"<leader>gah",
	[[<CMD> Gitsigns stage_hunk<CR>]],
	{ silent = true, noremap = true, desc = "Stage Hunk (Gitsigns)" }
)
vim.keymap.set("v", "<leader>gah", function()
	local gs = require("gitsigns")
	gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Stage Hunk - Visual Mode (Gitsigns)" })
vim.keymap.set(
	"n",
	"<leader>grb",
	[[<CMD> Gitsigns reset_buffer<CR>]],
	{ silent = true, noremap = true, desc = "Reset Buffer (Gitsigns)" }
)
vim.keymap.set(
	"n",
	"<leader>grh",
	[[<CMD> Gitsigns reset_hunk<CR>]],
	{ silent = true, noremap = true, desc = "Reset Hunk (Gitsigns)" }
)
vim.keymap.set("v", "<leader>grh", function()
	local gs = require("gitsigns")
	gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Reset Hunk - Visual Mode (Gitsigns)" })
vim.keymap.set(
	"n",
	"<leader>guh",
	[[<CMD> Gitsigns undo_stage_hunk<CR>]],
	{ silent = true, noremap = true, desc = "Undo Stage Hunk (Gitsigns)" }
)
vim.keymap.set(
	"n",
	"<leader>gh",
	[[<CMD> Gitsigns preview_hunk<CR>]],
	{ silent = true, noremap = true, desc = "Preview Hunk (Gitsigns)" }
)
vim.keymap.set(
	"n",
	"<leader>gtd",
	[[<CMD> Gitsigns toggle_deleted<CR>]],
	{ silent = true, noremap = true, desc = "Toggle Deleted (Gitsigns)" }
)
vim.keymap.set(
	"n",
	"<leader>gtl",
	[[<CMD> Gitsigns toggle_current_line_blame<CR>]],
	{ silent = true, noremap = true, desc = "Toggle Current Line Blame (Gitsigns)" }
)
vim.keymap.set(
	"n",
	"<leader>gd",
	[[<CMD> Gitsigns diffthis<CR>]],
	{ silent = true, noremap = true, desc = "Git Diff (Gitsigns)" }
)

vim.keymap.set("n", "<leader>cf", ":e %:p:h/", { desc = "Open File" })
vim.keymap.set("n", "<leader>t2", ":set tabstop=2 shiftwidth=2 softtabstop=2<CR>", { desc = "Set Tabstop 2" })
vim.keymap.set("n", "<leader>t4", ":set tabstop=4 shiftwidth=4 softtabstop=4<CR>", { desc = "Set Tabstop 4" })

vim.keymap.set("n", "<leader>cl", function()
	if require("trouble").is_open() then
		require("trouble").close()
		return
	end
	local qf_exists = false
	for _, win in pairs(vim.fn.getwininfo()) do
		if win["quickfix"] == 1 then
			qf_exists = true
		end
	end
	if qf_exists == true then
		vim.cmd("cclose")
		return
	end
	if not vim.tbl_isempty(vim.fn.getqflist()) then
		vim.cmd("copen")
		return
	end
	if vim.tbl_isempty(vim.fn.getqflist()) then
		print("Quickfix is empty")
		return
	end
end, { desc = "Toggle Quickfix" })

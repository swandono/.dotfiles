-- gitsigns
require('gitsigns').setup {
    current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 50,
        ignore_whitespace = false,
    },
    update_debounce = 100,
}
-- neogit
local neogit = require('neogit')
neogit.setup {}

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

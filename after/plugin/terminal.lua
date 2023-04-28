local Terminal = require('toggleterm.terminal').Terminal
local lazygit  = Terminal:new({
    cmd = "lazygit",
    hidden = true,
    direction = "float",
})
function _lazygit_toggle()
    lazygit:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>gk", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-]>", [[<CMD>exe v:count1 . "ToggleTerm"<CR>]])
vim.keymap.set("i", "<C-]>", [[<Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>]])

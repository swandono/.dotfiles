require("toggleterm").setup {
    open_mapping = [[<c-]>]],
    size = 50,
    shade_terminals = true,   -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
    start_in_insert = true,
    insert_mappings = true,   -- whether or not the open mapping applies in insert mode
    terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
    persist_size = true,
    direction = 'vertical'
}
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

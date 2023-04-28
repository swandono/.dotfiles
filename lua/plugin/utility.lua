local A = {
    'windwp/nvim-autopairs',
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
}
local B = {
    'windwp/nvim-ts-autotag',
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
}
local C = {
    'ThePrimeagen/harpoon',
    lazy = true,
    build = function()
        require('telescope').load_extension('harpoon')
    end,
}
local D = { 'dstein64/vim-startuptime', lazy = true, cmd = "StartupTime" }
local E = {
    'numToStr/Comment.nvim',
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
}

return { A, B, C, D, E }

local A = {
    'windwp/nvim-autopairs',
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
}
local B = {
    'windwp/nvim-ts-autotag',
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
}
local C = { 'dstein64/vim-startuptime', event = "VeryLazy", cmd = "StartupTime" }
local D = {
    'numToStr/Comment.nvim',
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
}

return { A, B, C, D }

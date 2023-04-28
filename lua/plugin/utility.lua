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
local E = {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" } },
    -- stylua: ignore
    keys = {
        { "<leader>qs", function() require("persistence").load() end,                desc = "Restore Session" },
        { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
        { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
    },
}


return { A, B, C, D, E }

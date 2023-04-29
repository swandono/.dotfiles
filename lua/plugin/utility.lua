local A = {
    "windwp/nvim-autopairs",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    config = function()
        require("nvim-autopairs").setup({})
    end,
}
local B = {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    config = function()
        require("nvim-ts-autotag").setup()
    end,
}
local C = { "dstein64/vim-startuptime", event = "VeryLazy", cmd = "StartupTime" }
local D = {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    config = function()
        require("Comment").setup()
    end,
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
local F = { "nvim-lua/plenary.nvim", event = "VeryLazy" }
local G = {
    "stevearc/dressing.nvim",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    init = function()
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.ui.select = function(...)
            require("lazy").load({ plugins = { "dressing.nvim" } })
            return vim.ui.select(...)
        end
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.ui.input = function(...)
            require("lazy").load({ plugins = { "dressing.nvim" } })
            return vim.ui.input(...)
        end
    end,
}
local H = {
    "echasnovski/mini.bufremove",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    version = false,
}

return { A, B, C, D, E, F, G, H }

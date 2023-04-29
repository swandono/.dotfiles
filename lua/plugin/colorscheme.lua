return {
    {
        "ellisonleao/gruvbox.nvim",
        event = "VimEnter",
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme gruvbox]])
        end,
        keys = {
            {
                "<leader>cg",
                function()
                    vim.cmd([[colorscheme gruvbox]])
                end,
            },
        },
    },
    {
        "folke/tokyonight.nvim",
        lazy = true,
        keys = {
            {
                "<leader>ct",
                function()
                    vim.cmd([[colorscheme tokyonight]])
                end,
            },
        },
        opts = { style = "moon" },
    },
    {
        "catppuccin/nvim",
        lazy = true,
        keys = {
            {
                "<leader>cc",
                function()
                    vim.cmd([[colorscheme catppuccin]])
                end,
            },
        },
        name = "catppuccin",
    },
    {
        "rmehri01/onenord.nvim",
        lazy = true,
        keys = {
            {
                "<leader>co",
                function()
                    vim.cmd([[colorscheme onenord]])
                end,
            },
        },
    },
    {
        "shaunsingh/moonlight.nvim",
        lazy = true,
        keys = {
            {
                "<leader>cm",
                function()
                    vim.cmd([[colorscheme moonlight]])
                end,
            },
        },
    },
    {
        "glepnir/zephyr-nvim",
        lazy = true,
        keys = {
            {
                "<leader>cz",
                function()
                    vim.cmd([[colorscheme zephyr]])
                end,
            },
        },
    },
}

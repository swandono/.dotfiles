return {
    {
        "ellisonleao/gruvbox.nvim",
        lazy = true,
        keys = {
            {
                "<leader>c1",
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
                "<leader>c2",
                function()
                    vim.cmd([[colorscheme tokyonight]])
                end,
            },
        },
        opts = { style = "moon" },
    },
    {
        "navarasu/onedark.nvim",
        event = "VimEnter",
        priority = 1000,
        config = function()
            require('onedark').setup {
                style = 'cool',
                -- transparent = {
                --     background = true,
                --     tabline = true,
                --     statusline = true,
                -- }
            }
            require('onedark').load()
        end,
        keys = {
            {
                "<leader>c3",
                function()
                    vim.cmd([[colorscheme onedark]])
                end,
            },
        },
        opts = { style = "cool" },
    }
}

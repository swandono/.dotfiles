return {
    {
        "ellisonleao/gruvbox.nvim",
        event = "VimEnter",
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme gruvbox]])
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = true,
        opts = { style = "moon" },
    },
    {
        "catppuccin/nvim",
        lazy = true,
        name = "catppuccin",
    },
    {
        "rmehri01/onenord.nvim",
        lazy = true,
    },
    {
        "shaunsingh/moonlight.nvim",
        lazy = true,
    },
    {
        "glepnir/zephyr-nvim",
        lazy = true,
    },
}

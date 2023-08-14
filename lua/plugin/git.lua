local A = {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    opts = {
        current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
            delay = 50,
            ignore_whitespace = false,
        },
        update_debounce = 100,
    },
    config = function(_, opts)
        require("gitsigns").setup(opts)
    end,
}
local B = {
    "NeogitOrg/neogit",
    lazy = true,
    cmd = "Neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "nvim-telescope/telescope.nvim", -- optional
        "sindrets/diffview.nvim",        -- optional
    },
    config = true
}
local C = { "tpope/vim-fugitive", event = { "BufReadPre", "BufNewFile" } }

return { A, B, C }

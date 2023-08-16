local A = {
    "nvim-lualine/lualine.nvim",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    opts = {
        options = {
            icons_enabled = true,
            theme = "auto",
            -- component_separators = { left = "", right = "" },
            -- section_separators = { left = "", right = "" },
            component_separators = { left = "│", right = "│" },
            section_separators = { left = "", right = "" },
            disabled_filetypes = {},
            always_divide_middle = true,
            globalstatus = true,
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { "filename" },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
        },
    },
}
local B = {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    opts = {
        char = "▏",
        -- char = "│",
        filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
        show_trailing_blankline_indent = false,
        show_current_context = false,
    },
}
local C = {
    "yamatsum/nvim-cursorline",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    opts = {
        cursorline = {
            enable = true,
            timeout = 0,
            number = false,
        },
        cursorword = {
            enable = false,
        },
    },
}
local D = { "kyazdani42/nvim-web-devicons", lazy = true }

return { A, B, C, D }

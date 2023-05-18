local A = {
    "nvim-lualine/lualine.nvim",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    opts = {
        options = {
            icons_enabled = true,
            theme = "auto",
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
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
    "akinsho/bufferline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        options = {
            -- stylua: ignore
            close_command = function(n) require("mini.bufremove").delete(n, false) end,
            -- stylua: ignore
            right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
            diagnostics = "nvim_lsp",
            always_show_bufferline = false,
            offsets = {
                {
                    filetype = "neo-tree",
                    text = "Neo-tree",
                    highlight = "Directory",
                    text_align = "left",
                },
            },
        },
    },
    dependencies = {
        {
            "echasnovski/mini.bufremove",
            event = { "BufReadPre", "BufNewFile", "InsertEnter" },
            version = false,
        },
    },
}
local C = {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    opts = {
        -- char = "▏",
        char = "│",
        filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
        show_trailing_blankline_indent = false,
        show_current_context = false,
    },
}
local D = {
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
local E = { "kyazdani42/nvim-web-devicons", lazy = true }

return { A, B, C, D, E }

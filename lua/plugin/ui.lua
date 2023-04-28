local A = {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    opts = {
        options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = {},
            always_divide_middle = true,
            globalstatus = true,
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff', 'diagnostics' },
            lualine_c = { { 'filename', path = 1 } },
            lualine_x = { 'encoding', 'fileformat', 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = { 'location' }
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { 'filename' },
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {}
        }
    }
}
local B = {
    'akinsho/bufferline.nvim',
    event = "VeryLazy",
    opts = {
        options = {
            -- stylua: ignore
            close_command = function(n) require("mini.bufremove").delete(n, false) end,
            -- stylua: ignore
            right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
            diagnostics = "nvim_lsp",
            always_show_bufferline = false,
        },
    },
}
local C = {
    'lukas-reineke/indent-blankline.nvim',
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        -- char = "▏",
        char = "│",
        filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
        show_trailing_blankline_indent = false,
        show_current_context = false,
    },
}
local D = {
    'yamatsum/nvim-cursorline',
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    opts = {
        cursorline = {
            enable = true,
            timeout = 0,
            number = false,
        },
        cursorword = {
            enable = false
        }
    }
}
local E = {
    'kyazdani42/nvim-tree.lua',
    event = "VeryLazy",
    cmd = "NvimTreeToggle",
    opts = {
        view = {
            width = 50
        }
    },
    config = function(_, opts)
        require("nvim-tree").setup(opts)
        vim.keymap.set("n", "<leader>rt", [[<CMD>NvimTreeRefresh<CR>]])
        vim.keymap.set("n", "<C-h>", [[<CMD>NvimTreeToggle<CR>]])
    end
}
local F = { 'kyazdani42/nvim-web-devicons', lazy = true }
local G = { 'nvim-lua/plenary.nvim' }
local H = { 'nvim-lua/popup.nvim' }
local I = {
    'stevearc/dressing.nvim',
    lazy = true
}

return { A, B, C, D, E, F, G, H, I }

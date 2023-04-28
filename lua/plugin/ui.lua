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
            always_show_bufferline = true,
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
local G = { 'nvim-lua/plenary.nvim', lazy = true }
local H = {
    'stevearc/dressing.nvim',
    lazy = true
}
local I = {
    'echasnovski/mini.starter',
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = "VimEnter",
    opts = function()
        local logo = table.concat({
            "          █▀ █░█░█ ▄▀█ █▄░█ █▀█ █▀▄ █▄░█ █▀█",
            "          ▄█ ▀▄▀▄▀ █▀█ █░▀█ █▄█ █▄▀ █░▀█ █▄█",
        }, "\n")
        local pad = string.rep(" ", 22)
        local new_section = function(name, action, section)
            return { name = name, action = action, section = pad .. section }
        end

        local starter = require("mini.starter")
        --stylua: ignore
        local config = {
            evaluate_single = true,
            header = logo,
            items = {
                new_section("Find file", "Telescope find_files", "Telescope"),
                new_section("Recent files", "Telescope oldfiles", "Telescope"),
                new_section("Grep text", "Telescope live_grep", "Telescope"),
                new_section("New file", "ene | startinsert", "Built-in"),
                new_section("Quit", "qa", "Built-in"),
                new_section("Session restore", [[lua require("persistence").load()]], "Session"),
            },
            content_hooks = {
                starter.gen_hook.adding_bullet(pad .. "░ ", false),
                starter.gen_hook.aligning("center", "center"),
            },
        }
        return config
    end,
    config = function(_, config)
        -- close Lazy and re-open when starter is ready
        if vim.o.filetype == "lazy" then
            vim.cmd.close()
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniStarterOpened",
                callback = function()
                    require("lazy").show()
                end,
            })
        end

        local starter = require("mini.starter")
        starter.setup(config)

        vim.api.nvim_create_autocmd("User", {
            pattern = "LazyVimStarted",
            callback = function()
                local stats = require("lazy").stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                local pad_footer = string.rep(" ", 8)
                starter.config.footer = pad_footer .. "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
                pcall(starter.refresh)
            end,
        })
    end,
}

return { A, B, C, D, E, F, G, H, I }

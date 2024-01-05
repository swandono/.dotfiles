local A = {
    {
        "folke/trouble.nvim",
        cmd = { "TroubleToggle", "Trouble" },
        opts = { use_diagnostic_signs = true },
        keys = {
            { "<leader>lf", "<cmd>TroubleToggle<cr>" },
            { "<leader>ld", "<cmd>TroubleToggle document_diagnostics<cr>",  desc = "Document Diagnostics (Trouble)" },
            { "<leader>lw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
            {
                "<leader>lp",
                function()
                    if require("trouble").is_open() then
                        require("trouble").previous({ skip_groups = true, jump = true })
                    end
                end,
                desc = "Previous trouble/quickfix item",
            },
            {
                "<leader>ln",
                function()
                    if require("trouble").is_open() then
                        require("trouble").next({ skip_groups = true, jump = true })
                    end
                end,
                desc = "Next trouble/quickfix item",
            },
        },
    },
}

local B = {
    {
        "nvim-neo-tree/neo-tree.nvim",
        event = { "BufReadPre", "BufNewFile", "InsertEnter" },
        dependencies = {
            { "MunifTanjim/nui.nvim", lazy = true },
        },
        keys = {
            {
                "<C-h>",
                function()
                    require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
                end,
                desc = "Explorer NeoTree (cwd)",
            },
            { "<leader>rt", "<C-h>", desc = "Explorer NeoTree (cwd)", remap = true },
        },
        deactivate = function()
            vim.cmd([[Neotree close]])
        end,
        init = function()
            vim.g.neo_tree_remove_legacy_commands = 1
            if vim.fn.argc() == 1 then
                local stat = vim.loop.fs_stat(vim.fn.argv(0))
                if stat and stat.type == "directory" then
                    require("neo-tree")
                end
            end
        end,
        opts = {
            filesystem = {
                bind_to_cwd = false,
                follow_current_file = true,
                use_libuv_file_watcher = true,
            },
            window = {
                mappings = {
                    ["<space>"] = "none",
                },
            },
            default_component_configs = {
                indent = {
                    with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
            },
        },
        config = function(_, opts)
            require("neo-tree").setup(opts)
            vim.api.nvim_create_autocmd("TermClose", {
                pattern = "*lazygit",
                callback = function()
                    if package.loaded["neo-tree.sources.git_status"] then
                        require("neo-tree.sources.git_status").refresh()
                    end
                end,
            })
        end,
    },
}

local C = {
    {
        "nvim-pack/nvim-spectre",
        -- stylua: ignore
        keys = {
            { "<leader>sp", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
        },
    },
}

local D = {
    {
        "folke/todo-comments.nvim",
        cmd = { "TodoTrouble", "TodoTelescope" },
        config = true,
        -- stylua: ignore
        keys = {
            { "<leader>tn", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
            { "<leader>tp", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
            { "<leader>tl", "<cmd>TodoQuickFix<cr>",                             desc = "Todo (QuickFix)" },
            { "<leader>tt", "<cmd>TodoTrouble<cr>",                              desc = "Todo (Trouble)" },
            { "<leader>tT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",      desc = "Todo/Fix/Fixme (Trouble)" },
            { "<leader>ts", "<cmd>TodoTelescope<cr>",                            desc = "Todo" },
            { "<leader>tS", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",    desc = "Todo/Fix/Fixme" },
        },
    },
}

local E = {
    {
        "github/copilot.vim",
        cmd = "Copilot",
        event = { "BufReadPre", "BufNewFile", "InsertEnter" },
        config = function()
            vim.g.copilot_no_tab_map = true
            vim.b.copilot_enable = true
            vim.g.copilot_filetypes = {
                ['dap-repl'] = false,
            }
            vim.keymap.set('i', '<C-j>', 'copilot#Accept("<CR>")',
                { expr = true, replace_keycodes = false, desc = "Accept Copilot Suggestion" })
            vim.keymap.set('i', '<C-k>', '<Plug>(copilot-accept-word)', { desc = "Accept Copilot Word" })
        end,
    }
}

local F = {
    "laytan/cloak.nvim",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    config = function()
        require('cloak').setup({
            enabled = true,
            cloak_character = '*',
            -- The applied highlight group (colors) on the cloaking, see `:h highlight`.
            highlight_group = 'Comment',
            -- Applies the length of the replacement characters for all matched
            -- patterns, defaults to the length of the matched pattern.
            cloak_length = nil, -- Provide a number if you want to hide the true length of the value.
            -- Wether it should try every pattern to find the best fit or stop after the first.
            try_all_patterns = true,
            patterns = {
                {
                    -- Match any file starting with '.env'.
                    -- This can be a table to match multiple file patterns.
                    file_pattern = '*.env*',
                    -- Match an equals sign and any character after it.
                    -- This can also be a table of patterns to cloak,
                    -- example: cloak_pattern = { ':.+', '-.+' } for yaml files.
                    cloak_pattern = '=.+',
                    -- A function, table or string to generate the replacement.
                    -- The actual replacement will contain the 'cloak_character'
                    -- where it doesn't cover the original text.
                    -- If left emtpy the legacy behavior of keeping the first character is retained.
                    replace = nil,
                },
            },
        })
    end
}

return { A, B, C, D, E, F }

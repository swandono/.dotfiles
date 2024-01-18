local A = {
    "folke/trouble.nvim",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    opts = { use_diagnostic_signs = true },
    config = function(_, opts)
        require("trouble").setup(opts)
        vim.keymap.set("n", "<leader>td", "<cmd>TroubleToggle document_diagnostics<cr>",
            { silent = true, noremap = true, desc = "Document Diagnostics (Trouble)" })
        vim.keymap.set("n", "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<cr>",
            { silent = true, noremap = true, desc = "Workspace Diagnostics (Trouble)" })
        vim.keymap.set("n", "<leader>cp", function()
            if require("trouble").is_open() then
                require("trouble").previous({ skip_groups = true, jump = true })
            else
                local ok, result = pcall(vim.cmd, [[cprev]])
                if not ok then
                    print("No previous trouble or quickfix item")
                end
            end
        end, { desc = "Previous trouble/quickfix" })
        vim.keymap.set("n", "<leader>cn", function()
            if require("trouble").is_open() then
                require("trouble").next({ skip_groups = true, jump = true })
            else
                local ok, result = pcall(vim.cmd, [[cnext]])
                if not ok then
                    print("No next trouble or quickfix item")
                end
            end
        end, { desc = "Next trouble/quickfix" })
        vim.keymap.set("n", "<leader>tr", function() require("trouble").toggle("lsp_references") end,
            { desc = "LSP References (Trouble)" })
    end,
}

local B = {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
        { "MunifTanjim/nui.nvim", lazy = true },
    },
    keys = {
        { "<C-h>" },
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
        vim.keymap.set("n", "<C-h>", function()
            require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
        end, { silent = true, noremap = true, desc = "Explorer NeoTree (cwd)" })
    end,
}

local C = {
    "nvim-pack/nvim-spectre",
    -- stylua: ignore
    keys = {
        { "<leader>sp" },
    },
    config = function()
        vim.keymap.set("n", "<leader>sp", function()
            require("spectre").open()
        end, { silent = true, noremap = true, desc = "Replace in files (Spectre)" })
    end,
}

local D = {
    "folke/todo-comments.nvim",
    keys = {
        { "<leader>tl" },
        { "<leader>tL" },
        { "<leader>ts" },
        { "<leader>tS" },
    },
    config = function()
        require("todo-comments").setup({})
        vim.keymap.set("n", "<leader>tl", "<cmd>TodoQuickFix<cr>",
            { silent = true, noremap = true, desc = "Todo (QuickFix)" })
        vim.keymap.set("n", "<leader>tL", "<cmd>TodoQuickFix keywords=TODO,FIX,FIXME<cr>",
            { silent = true, noremap = true, desc = "Todo/Fix/Fixme (QuickFix)" })
        vim.keymap.set("n", "<leader>ts", "<cmd>TodoTelescope<cr>",
            { silent = true, noremap = true, desc = "Todo" })
        vim.keymap.set("n", "<leader>tS", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",
            { silent = true, noremap = true, desc = "Todo/Fix/Fixme" })
    end,
}

local E = {
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
        vim.keymap.set('n', '<M-p>', '<cmd>Copilot panel<cr>', { desc = "Show Copilot Panel" })
    end,
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

local G = {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()
        vim.keymap.set("n", "<C-n>", function() harpoon:list():next() end, { desc = "Harpoon nav next" })
        vim.keymap.set("n", "<C-p>", function() harpoon:list():prev() end, { desc = "Harpoon nav prev" })
        vim.keymap.set("n", "<M-j>", function() harpoon:list():select(1) end, { desc = "Harpoon nav file 1" })
        vim.keymap.set("n", "<M-k>", function() harpoon:list():select(2) end, { desc = "Harpoon nav file 2" })
        vim.keymap.set("n", "<M-l>", function() harpoon:list():select(3) end, { desc = "Harpoon nav file 3" })
        vim.keymap.set("n", "<M-u>", function() harpoon:list():select(4) end, { desc = "Harpoon nav file 4" })
        vim.keymap.set("n", "<M-i>", function() harpoon:list():select(5) end, { desc = "Harpoon nav file 5" })
        vim.keymap.set("n", "<M-o>", function() harpoon:list():select(6) end, { desc = "Harpoon nav file 6" })
        vim.keymap.set("n", "<leader>ma", function() harpoon:list():append() end, { desc = "Harpoon mark add file" })
        vim.keymap.set("n", "<leader>ml", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
            { desc = "Harpoon toggle quick menu" })
    end,
}

return { A, B, C, D, E, F, G }

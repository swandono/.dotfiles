return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    dependencies = {
        {
            "ThePrimeagen/harpoon",
            event = { "BufReadPre", "BufNewFile", "InsertEnter" },
            build = function()
                require("telescope").load_extension("harpoon")
            end,
        },
    },
    version = false,
    opts = {
        extensions = {
            fzf = {
                fuzzy = true,                   -- false will only do exact matching
                override_generic_sorter = true, -- override the generic sorter
                override_file_sorter = true,    -- override the file sorter
                case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            },
        },
    },
    config = function()
        local tele = require("telescope.builtin")
        vim.keymap.set(
            "n",
            "<leader>ls",
            function()
                local word = vim.fn.expand("<cword>")
                tele.grep_string({ search = word })
            end,
            { silent = true, noremap = true, desc = "Telescope grep word" }
        )
        vim.keymap.set(
            "n",
            "<leader>lS",
            function()
                local word = vim.fn.expand("<cWORD>")
                tele.grep_string({ search = word })
            end,
            { silent = true, noremap = true, desc = "Telescope grep words" }
        )
        vim.keymap.set("n", "<leader>js", tele.lsp_document_symbols, { desc = "Telescope LSP document symbols" })
        vim.keymap.set("n", "<leader>ks", tele.keymaps, { desc = "Telescope keymaps" })
        vim.keymap.set("n", "<leader>hs", tele.help_tags, { desc = "Telescope help tags" })
        vim.keymap.set("n", "<leader>bs", tele.git_branches, { desc = "Telescope git branches" })
        vim.keymap.set("n", "<C-j>", tele.buffers, { desc = "Telescope buffers" })
        vim.keymap.set("n", "<C-k>", tele.find_files, { desc = "Telescope find files" })
        vim.keymap.set("n", "<C-l>", tele.live_grep, { desc = "Telescope live grep" })
        vim.keymap.set("n", "<leader>vd", tele.lsp_definitions, { desc = "Telescope LSP definitions" })
        vim.keymap.set("n", "<leader>vi", tele.lsp_implementations, { desc = "Telescope LSP implementations" })
        vim.keymap.set("n", "<leader>vt", tele.lsp_type_definitions, { desc = "Telescope LSP type definitions" })
        vim.keymap.set("n", "<leader>vr", tele.lsp_references, { desc = "Telescope LSP references" })

        local harp_ui = require("harpoon.ui")
        local harp_mark = require("harpoon.mark")
        vim.keymap.set("n", "<C-n>", harp_ui.nav_next, { desc = "Harpoon nav next" })
        vim.keymap.set("n", "<C-p>", harp_ui.nav_prev, { desc = "Harpoon nav prev" })
        vim.keymap.set("n", "<M-j>", function()
            harp_ui.nav_file(1)
        end, { desc = "Harpoon nav file 1" })
        vim.keymap.set("n", "<M-k>", function()
            harp_ui.nav_file(2)
        end, { desc = "Harpoon nav file 2" })
        vim.keymap.set("n", "<M-l>", function()
            harp_ui.nav_file(3)
        end, { desc = "Harpoon nav file 3" })
        vim.keymap.set("n", "<M-u>", function()
            harp_ui.nav_file(4)
        end, { desc = "Harpoon nav file 4" })
        vim.keymap.set("n", "<M-i>", function()
            harp_ui.nav_file(5)
        end, { desc = "Harpoon nav file 5" })
        vim.keymap.set("n", "<M-o>", function()
            harp_ui.nav_file(6)
        end, { desc = "Harpoon nav file 6" })
        vim.keymap.set("n", "<leader>ma", harp_mark.add_file, { desc = "Harpoon mark add file" })
        vim.keymap.set("n", "<leader>mm", harp_ui.toggle_quick_menu, { desc = "Harpoon toggle quick menu" })
    end,
}

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
                fuzzy = true,       -- false will only do exact matching
                override_generic_sorter = true, -- override the generic sorter
                override_file_sorter = true, -- override the file sorter
                case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            },
        },
    },
    config = function()
        local tele = require("telescope.builtin")
        vim.keymap.set("n", "<leader>js", tele.marks, {})
        vim.keymap.set("n", "<leader>ks", tele.current_buffer_fuzzy_find, {})
        vim.keymap.set(
            "n",
            "<leader>ls",
            [[<CMD>lua require('telescope.builtin').grep_string()<CR>]],
            { silent = true, noremap = true }
        )
        vim.keymap.set("n", "<leader>ss", tele.git_status, {})
        vim.keymap.set("n", "<C-j>", tele.buffers, {})
        vim.keymap.set("n", "<C-k>", tele.find_files, {})
        vim.keymap.set("n", "<C-l>", tele.live_grep, {})
        vim.keymap.set("n", "<leader>vd", tele.lsp_definitions, {})
        vim.keymap.set("n", "<leader>vj", tele.lsp_implementations, {})
        vim.keymap.set("n", "<leader>vk", tele.lsp_type_definitions, {})
        vim.keymap.set("n", "<leader>vl", tele.lsp_references, {})

        local harp_ui = require("harpoon.ui")
        local harp_mark = require("harpoon.mark")
        vim.keymap.set("n", "<C-n>", harp_ui.nav_next, {})
        vim.keymap.set("n", "<C-p>", harp_ui.nav_prev, {})
        vim.keymap.set("n", "<leader>m1", function()
            harp_ui.nav_file(1)
        end)
        vim.keymap.set("n", "<leader>m2", function()
            harp_ui.nav_file(2)
        end)
        vim.keymap.set("n", "<leader>m3", function()
            harp_ui.nav_file(3)
        end)
        vim.keymap.set("n", "<leader>m4", function()
            harp_ui.nav_file(4)
        end)
        vim.keymap.set("n", "<leader>m5", function()
            harp_ui.nav_file(5)
        end)
        vim.keymap.set("n", "<leader>ma", harp_mark.add_file, {})
        vim.keymap.set("n", "<leader>mm", harp_ui.toggle_quick_menu, {})
        vim.keymap.set("n", "<leader>mt", [[<CMD> Telescope harpoon marks<CR>]])
    end,
}

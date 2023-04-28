return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            { 'neovim/nvim-lspconfig' }, -- Required
            {
                -- Optional
                'williamboman/mason.nvim',
                build = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end,
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional
        },
        opts = function()
            local lsp = require("lsp-zero")

            lsp.preset("recommended")

            lsp.ensure_installed({
                'tsserver',
                'rust_analyzer',
                'gopls'
            })

            -- Fix Undefined global 'vim'
            lsp.nvim_workspace()

            lsp.set_preferences({
                suggest_lsp_servers = false,
                sign_icons = {
                    error = 'E',
                    warn = 'W',
                    hint = 'H',
                    info = 'I'
                }
            })

            lsp.on_attach(function(client, bufnr)
                local opts = { buffer = bufnr, remap = false }

                vim.keymap.set("n", "gd", function() vim.lsp.buf.definition {} end, opts)
                vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.hover() end, opts)
                vim.keymap.set("n", "<leader>ff", function() vim.lsp.buf.format { async = true } end, opts)
                vim.keymap.set("n", "<leader>va", function() vim.lsp.buf.code_action() end, opts)
                vim.keymap.set("n", "<leader>vf", function() vim.diagnostic.open_float() end, opts)
                vim.keymap.set("n", "<leader>vh", function() vim.lsp.buf.hover() end, opts)
                vim.keymap.set("n", "<leader>vn", function() vim.diagnostic.goto_next() end, opts)
                vim.keymap.set("n", "<leader>vp", function() vim.diagnostic.goto_prev() end, opts)
                vim.keymap.set("n", "<leader>vr", function() vim.lsp.buf.rename() end, opts)
                vim.keymap.set("n", "<leader>vs", function() vim.lsp.buf.signature_help() end, opts)
            end)

            lsp.setup()

            vim.diagnostic.config({
                virtual_text = true
            })
        end
    },
}

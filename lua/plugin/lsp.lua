return {
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v2.x",
        event = { "BufReadPre", "BufNewFile", "InsertEnter" },
        dependencies = {
            { "neovim/nvim-lspconfig" }, -- Required
            {
                -- Optional
                "williamboman/mason.nvim",
                build = function()
                    pcall(vim.cmd, "MasonUpdate")
                end,
            },
            { "williamboman/mason-lspconfig.nvim" }, -- Optional
        },
        opts = function()
            local lsp = require("lsp-zero")

            lsp.preset("recommended")

            lsp.ensure_installed({
                "vtsls",
                "rust_analyzer",
                "gopls",
                "clangd",
            })

            -- Fix Undefined global 'vim'
            lsp.nvim_workspace()

            lsp.set_preferences({
                suggest_lsp_servers = false,
                sign_icons = {
                    error = "E",
                    warn = "W",
                    hint = "H",
                    info = "I",
                },
            })

            lsp.on_attach(function(_, bufnr)
                vim.keymap.set("n", "K", function()
                    vim.lsp.buf.hover()
                end, { buffer = bufnr, remap = false, desc = "Hover (LSP)" })
                vim.keymap.set("i", "<C-h>", function()
                    vim.lsp.buf.signature_help()
                end, { buffer = bufnr, remap = false, desc = "Signature help (LSP)" })
                vim.keymap.set("n", "<leader>ff", function()
                    vim.lsp.buf.format({ async = true })
                end, { buffer = bufnr, remap = false, desc = "Format (LSP)" })
                vim.keymap.set("n", "<leader>va", function()
                    vim.lsp.buf.code_action()
                end, { buffer = bufnr, remap = false, desc = "Code action (LSP)" })
                vim.keymap.set("n", "<leader>vf", function()
                    vim.diagnostic.open_float()
                end, { buffer = bufnr, remap = false, desc = "Open float (LSP)" })
                vim.keymap.set("n", "<leader>vn", function()
                    vim.diagnostic.goto_next()
                end, { buffer = bufnr, remap = false, desc = "Go to next (LSP)" })
                vim.keymap.set("n", "<leader>vp", function()
                    vim.diagnostic.goto_prev()
                end, { buffer = bufnr, remap = false, desc = "Go to previous (LSP)" })
                vim.keymap.set("n", "<leader>vr", function()
                    vim.lsp.buf.rename()
                end, { buffer = bufnr, remap = false, desc = "Rename (LSP)" })
            end)

            lsp.setup()

            vim.diagnostic.config({
                virtual_text = true,
            })
        end,
    },
    {
        "mhartington/formatter.nvim",
        event = { "BufReadPre", "BufNewFile", "InsertEnter" },
        config = function()
            local function python()
                return {
                    exe = "black",
                    args = {
                        '-q',
                        '-',
                    },
                    stdin = true,
                }
            end
            local function java()
                return {
                    exe = "clang-format",
                    args = { "--style=Google", "--assume-filename=.java" },
                    stdin = true
                }
            end
            require("formatter").setup({
                logging = true,
                filetype = {
                    javascript = { require("formatter.filetypes.javascript").prettierd },
                    javascriptreact = { require("formatter.filetypes.javascript").prettierd },
                    typescript = { require("formatter.filetypes.javascript").prettierd },
                    typescriptreact = { require("formatter.filetypes.javascript").prettierd },
                    css = { require("formatter.filetypes.javascript").prettierd },
                    vue = { require("formatter.filetypes.javascript").prettierd },
                    json = { require("formatter.filetypes.javascript").prettierd },
                    yaml = { require("formatter.filetypes.javascript").prettierd },
                    markdown = { require("formatter.filetypes.javascript").prettierd },
                    html = { require("formatter.filetypes.javascript").prettierd },
                    python = { python },
                    java = { java }
                },
                ["*"] = {
                    require("formatter.filetypes.any").remove_trailing_whitespace
                }
            })
            vim.keymap.set("n", "<leader>fF", [[<CMD> Format<CR>]], { silent = true, desc = "Format using formatter" })
            vim.keymap.set("n", "<leader>fW", [[<CMD> FormatWrite<CR>]],
                { silent = true, desc = "Format using formatter and write" })
        end,
    },
}

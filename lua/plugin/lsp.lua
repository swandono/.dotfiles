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
                local opts = { buffer = bufnr, remap = false }

                vim.keymap.set("n", "gd", function()
                    vim.lsp.buf.definition({})
                end, opts)
                vim.keymap.set("n", "K", function()
                    vim.lsp.buf.hover()
                end, opts)
                vim.keymap.set("i", "<C-h>", function()
                    vim.lsp.buf.signature_help()
                end, opts)
                vim.keymap.set("n", "<leader>ff", function()
                    vim.lsp.buf.format({ async = true })
                end, opts)
                vim.keymap.set("n", "<leader>va", function()
                    vim.lsp.buf.code_action()
                end, opts)
                vim.keymap.set("n", "<leader>vf", function()
                    vim.diagnostic.open_float()
                end, opts)
                vim.keymap.set("n", "<leader>vn", function()
                    vim.diagnostic.goto_next()
                end, opts)
                vim.keymap.set("n", "<leader>vp", function()
                    vim.diagnostic.goto_prev()
                end, opts)
                vim.keymap.set("n", "<leader>vc", function()
                    vim.lsp.buf.rename()
                end, opts)
                vim.keymap.set("n", "<leader>vl", function()
                    vim.lsp.buf.references()
                end, opts)
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
            local function prettier()
                return {
                    exe = "prettierd",
                    args = { vim.api.nvim_buf_get_name(0) },
                    stdin = true
                }
            end
            local function go()
                return {
                    exe = "gofmt",
                    stdin = true,
                }
            end
            local function rust()
                return {
                    exe = "rustfmt",
                    stdin = true,
                }
            end
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
                    javascript = { prettier },
                    javascriptreact = { prettier },
                    typescript = { prettier },
                    typescriptreact = { prettier },
                    css = { prettier },
                    scss = { prettier },
                    vue = { prettier },
                    json = { prettier },
                    jsonc = { prettier },
                    yaml = { prettier },
                    markdown = { prettier },
                    html = { prettier },
                    go = { go },
                    rust = { rust },
                    python = { python },
                    java = { java }
                },
                ["*"] = {
                    require("formatter.filetypes.any").remove_trailing_whitespace
                }
            })
            vim.keymap.set("n", "<leader>fF", [[<CMD> Format<CR>]])
            vim.keymap.set("n", "<leader>fw", [[<CMD> FormatWrite<CR>]])
        end,
    },
}

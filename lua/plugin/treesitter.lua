local A = {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    build = ":TSUpdate",
    dependencies = {
        { "nvim-treesitter/nvim-treesitter-context", lazy = true },
    },
    opts = {
        highlight = {
            enable = true,
            disable = { "dap-repl" },
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "gni",
                node_incremental = "gnn",
                scope_incremental = "gnb",
                node_decremental = "gnm",
            },
        },
        rainbow = {
            enable = true,
            extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
            max_file_lines = nil, -- Do not enable for files with more than n lines, int
        },
        autotag = {
            enable = true,
        },
        sync_install = false,
        auto_install = true,
    },
    config = function(_, opts)
        if type(opts.ensure_installed) == "table" then
            ---@type table<string, boolean>
            local added = {}
            opts.ensure_installed = vim.tbl_filter(function(lang)
                if added[lang] then
                    return false
                end
                added[lang] = true
                return true
            end, opts.ensure_installed)
        end
        require("nvim-treesitter.configs").setup(opts)
        require 'treesitter-context'.setup {}
    end,
}

return { A }

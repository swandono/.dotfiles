return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
        { 'neovim/nvim-lspconfig' }, -- Required
        { 'onsails/lspkind-nvim' },
        {
            -- Optional
            'williamboman/mason.nvim',
            build = function()
                pcall(vim.cmd, 'MasonUpdate')
            end,
        },
        { 'williamboman/mason-lspconfig.nvim' }, -- Optional

        -- Autocompletion
        { 'hrsh7th/nvim-cmp' },
        { 'hrsh7th/cmp-buffer' },
        { 'hrsh7th/cmp-path',                 lazy = true },
        { 'hrsh7th/cmp-nvim-lsp',             lazy = true },
        { 'hrsh7th/cmp-nvim-lua' },
        { 'hrsh7th/cmp-cmdline',              lazy = true },

        -- Snippets
        { 'L3MON4D3/LuaSnip' },
        { 'rafamadriz/friendly-snippets',     lazy = true },
        { 'saadparwaiz1/cmp_luasnip',         lazy = true },
    }
}

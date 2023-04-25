-- Add additional capabilities supported by nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
-- Setup lspconfig.
require("mason").setup()
require("mason-lspconfig").setup()
local lspconfig = require('lspconfig')
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
local servers = require("mason-lspconfig").get_installed_servers()

local on_attach = function(client, bufnr)
    local opts = {buffer = bufnr, remap = false}

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition{} end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>ff", function() vim.lsp.buf.format{async = true} end, opts)
    vim.keymap.set("n", "<leader>va", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vf", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>vh", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vn", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "<leader>vp", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vr", function() vim.lsp.buf.rename()  end, opts)
    vim.keymap.set("n", "<leader>vs", function() vim.lsp.buf.signature_help() end, opts)
end

for _, lsp in pairs(servers) do
    lspconfig[lsp].setup {
        capabilities = capabilities,
        on_attach = on_attach,
        -- flags = lsp_flags,
    }
end
local cmp = require'cmp'
local lspkind = require('lspkind')
local luasnip = require("luasnip")
local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
cmp.setup({
    snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
        luasnip.lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
    },
    window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
    },
    mapping = {
        ["<C-n>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        elseif has_words_before() then
            cmp.complete()
        else
            fallback()
        end
        end, { "i", "s" }),

        ["<C-p>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
        else
            fallback()
        end
        end, { "i", "s" }),

        ['<C-c>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- For luasnip users.
        { name = 'buffer' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'path' }
    }),
    formatting = {
        format = lspkind.cmp_format({with_text = true, maxwidth = 50})
    },
})
-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        -- { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
        { name = 'buffer' }
    })
})
-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})
-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline' }
    })
})

require("luasnip.loaders.from_vscode").lazy_load({paths = "/Users/swandono/.config/nvim/my_snips"})

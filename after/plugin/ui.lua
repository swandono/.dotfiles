require'indent_blankline'.setup()
require'nvim-tree'.setup {
    view = {
        width = 50
    }
}
require'nvim-cursorline'.setup {
    cursorline = {
        enable = true,
        timeout = 0,
        number = false,
    },
    cursorword = {
        enable = false
    }
}
require'bufferline'.setup()
require'nvim-autopairs'.setup()
require'lualine'.setup()

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
require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {},
        always_divide_middle = true,
        globalstatus = true,
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {{'filename', path = 1}},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    }
}

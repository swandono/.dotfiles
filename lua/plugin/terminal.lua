return {
    'akinsho/toggleterm.nvim',
    lazy = true,
    opts = {
        open_mapping = [[<c-]>]],
        size = 50,
        shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
        persist_size = true,
        direction = 'vertical'
    }
}

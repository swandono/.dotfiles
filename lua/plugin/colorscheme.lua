return {
    {
        "swandono/onedark.nvim",
        event = "VimEnter",
        priority = 1000,
        config = function()
            require('onedark').setup {
                style = 'cool',
                transparent = {
                    background = true,
                    tabline = true,
                    statusline = true,
                }
            }
            require('onedark').load()
        end,
        opts = { style = "cool" },
    }
}

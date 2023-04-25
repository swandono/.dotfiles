local A = {
    "nvim-treesitter/nvim-treesitter",
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })
    end,
}
local B = {'nvim-treesitter/nvim-treesitter-textobjects'}

return { A, B }

local A = { 'lewis6991/gitsigns.nvim' }
local B = { 'TimUntersberger/neogit', lazy = true, cmd = "Neogit", dependencies = { 'nvim-lua/plenary.nvim' } }
local C = { 'tpope/vim-fugitive' }

return { A, B, C }

local A = { 'nvim-lualine/lualine.nvim' }
local B = { 'akinsho/bufferline.nvim' }
local C = { 'lukas-reineke/indent-blankline.nvim', lazy = true }
local D = { 'yamatsum/nvim-cursorline', lazy = true }
local E = { 'kyazdani42/nvim-tree.lua', lazy = true, event = "VeryLazy", cmd = "NvimTreeToggle" }
local F = { 'kyazdani42/nvim-web-devicons', lazy = true }
local G = { 'nvim-lua/plenary.nvim' }
local H = { 'nvim-lua/popup.nvim' }
local I = { 'stevearc/dressing.nvim' }

return { A, B, C, D, E, F, G, H, I }

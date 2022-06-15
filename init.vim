""""""""""""""""""""""""
"" SET
""""""""""""""""""""""""

" Base
set exrc
set guicursor=
set relativenumber
set nohlsearch
set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set termguicolors
set scrolloff=8
set noshowmode
set completeopt=menu,menuone,noselect
set signcolumn=yes
set encoding=UTF-8
set laststatus=3

" Other
set cmdheight=2
set updatetime=50
set shortmess+=c
set path+=**
set wildmode=longest,list,full
set wildmenu
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

" Ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*

""""""""""""""""""""""""
"" PLUGIN
""""""""""""""""""""""""

call plug#begin('~/.vim/plugged')

" LSP Plugins
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'
Plug 'simrat39/symbols-outline.nvim'
Plug 'williamboman/nvim-lsp-installer'

" Completion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'

" Neovim Tree Sitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'romgrk/nvim-treesitter-context'
Plug 'p00f/nvim-ts-rainbow'

" Debugger Plugins
Plug 'mfussenegger/nvim-dap'
Plug 'Pocco81/DAPInstall.nvim'
Plug 'szw/vim-maximizer'

" Snippets
Plug 'L3MON4D3/LuaSnip'
Plug 'rafamadriz/friendly-snippets'
Plug 'saadparwaiz1/cmp_luasnip'

" Language
Plug 'rust-lang/rust.vim'
Plug 'darrikonn/vim-gofmt'
Plug 'tomlion/vim-solidity'
Plug 'ray-x/go.nvim'
Plug 'ray-x/guihua.lua'

" Git
Plug 'tanvirtin/vgit.nvim'
Plug 'TimUntersberger/neogit'
Plug 'sindrets/diffview.nvim'

" Undo
Plug 'mbbill/undotree'

" Compiler
Plug 'tpope/vim-dispatch'

" Theme
Plug 'gruvbox-community/gruvbox'
Plug 'vim-conf-live/vimconflive2021-colorscheme'
Plug 'flazz/vim-colorschemes'
Plug 'chriskempson/base16-vim'
Plug 'kyazdani42/nvim-web-devicons'

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

" vim-rfc!!
Plug 'mhinz/vim-rfc'

" Prettier
Plug 'sbdchd/neoformat'

" Status Bar
Plug 'nvim-lualine/lualine.nvim'

" Tab Buffer
Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }

" Tree
Plug 'kyazdani42/nvim-tree.lua'

" Toggle Terminal
Plug 'akinsho/toggleterm.nvim', { 'tag': 'v1.*' }

" Comment
Plug 'numToStr/Comment.nvim'

" Line
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'yamatsum/nvim-cursorline'

" Pairs
Plug 'windwp/nvim-autopairs'

" Stratup
Plug 'goolord/alpha-nvim'

" Markdown
Plug 'ellisonleao/glow.nvim', {'branch': 'main'}

call plug#end()

""""""""""""""""""""""""
"" MAP & OTHER's
""""""""""""""""""""""""

colorscheme gruvbox
highlight normal
let g:vim_be_good_log_file = 1
let g:vim_apm_log = 1
let g:neoformat_try_node_exe = 1
if executable('rg')
    let g:rg_derive_root='true'
endif
let loaded_matchparen = 1
let mapleader = " "

" Telescope
nnoremap <leader>ps :lua require('telescope.builtin').live_grep()<CR>
nnoremap <leader>fs <cmd>lua require('telescope.builtin').find_files()<CR>
nnoremap <leader>ls :lua require('telescope.builtin').grep_string({ search = <C-r><C-w>})<CR>

" Undo
nnoremap <leader>u :UndotreeShow<CR>

" Resize Windows
nnoremap <Leader>] :vertical resize +5<CR>
nnoremap <Leader>[ :vertical resize -5<CR>
nnoremap <Leader>rp :resize 100<CR>

" Tab/Buffer Navigation
nnoremap <silent><leader>b[ :BufferLineCyclePrev<CR>
nnoremap <silent><leader>b] :BufferLineCycleNext<CR>
nnoremap <silent><leader>b, :BufferLineMovePrev<CR>
nnoremap <silent><leader>b. :BufferLineMoveNext<CR>
nnoremap <silent><leader>be :BufferLineSortByExtension<CR>
nnoremap <silent><leader>bf :BufferLineSortByDirectory<CR>
nnoremap <leader>bd :bd<CR>
nnoremap <C-j> :b<space>

" Copy Paste Delete
nnoremap <leader>y "*y
vnoremap <leader>y "*y
nnoremap <leader>p[ "*p
vnoremap <leader>p[ "*p
nnoremap <leader>p] "*P
vnoremap <leader>p] "*P
nnoremap <leader>d "_d
vnoremap <leader>d "_d
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" LSP
nnoremap <leader>vd :lua vim.lsp.buf.definition()<CR>
nnoremap <leader>vi :lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>vs :lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>vr :lua vim.lsp.buf.references() <CR>
nnoremap <leader>vn :lua vim.lsp.buf.rename() <CR>
nnoremap <leader>vh :lua vim.lsp.buf.hover()<CR>
nnoremap <leader>vf :lua vim.lsp.buf.formatting()<CR>
nnoremap <leader>va :lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>v[ :lua vim.diagnostic.goto_prev()<CR>
nnoremap <leader>v] :lua vim.diagnostic.goto_next()<CR>
nnoremap <leader>ve :lua vim.diagnostic.open_float()<CR>

" Tree
nnoremap <C-n>l :NvimTreeRefresh<CR>
nnoremap <C-l> :NvimTreeToggle<CR>

" Toggle Terminal
nnoremap <silent><C-k> :ToggleTerm size=50 direction=vertical<CR>
inoremap <silent><C-k> <Esc>:ToggleTerm size=50 direction=vertical<CR>
nnoremap <silent><C-t>h :ToggleTerm size=15 direction=horizontal<CR>
inoremap <silent><C-t>h <Esc>:ToggleTerm size=15 direction=horizontal<CR>
nnoremap <silent><C-t>f :ToggleTerm direction=float<CR>
inoremap <silent><C-t>f <Esc>:ToggleTerm direction=float<CR>

" Snip
snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<CR>
snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<CR>

" Git
nnoremap <leader>gn :Neogit<CR>
nnoremap <leader>gc :VGit checkout<space>
nnoremap <leader>gk :VGit hunk_up<CR>
nnoremap <leader>gj :VGit hunk_down<CR>
nnoremap <leader>gh :VGit buffer_hunk_preview<CR>
nnoremap <leader>g. :VGit buffer_hunk_stage<CR>
nnoremap <leader>g, :VGit buffer_hunk_reset<CR>
nnoremap <leader>gg :!git<space>
nnoremap <leader>gy :!git commit<space>
nnoremap <leader>gq :!git branch<space>
nnoremap <leader>ga :!git add .<CR>
nnoremap <leader>gs :!git status<CR>
nnoremap <leader>g/ :!git branch<CR>
nnoremap <leader>go :!git pull<CR>
nnoremap <leader>gi :!git fetch<CR>
nnoremap <leader>g0 :!git push<CR>
nnoremap <leader>gd :VGit project_diff_preview<CR>
nnoremap <leader>gl :VGit project_logs_preview<CR>
nnoremap <leader>gtg :VGit toggle_live_gutter<CR>
nnoremap <leader>gtb :VGit toggle_live_blame<CR>
nnoremap <leader>gtp :VGit toggle_diff_preference<CR>
nnoremap <leader>gbh :VGit buffer_hunk_preview<CR>
nnoremap <leader>gbs :VGit buffer_stage<CR>
nnoremap <leader>gbu :VGit buffer_unstage<CR>
nnoremap <leader>gbr :VGit buffer_reset<CR>
nnoremap <leader>gps :VGit project_stage_all<CR>
nnoremap <leader>gpu :VGit project_unstage_all<CR>
nnoremap <leader>gpr :VGit project_reset_all<CR>

" Others
nnoremap <Leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>
nnoremap <leader>x :silent !chmod +x %<CR>
nnoremap <leader>1 :set nowrap!<CR>
nnoremap <leader>4 :LspRestart<CR>
nnoremap <leader>5 :edit<CR>

" Close
inoremap <C-c> <esc>

" Formatter
nnoremap <silent> <leader>fn :Neoformat<CR>

" Markdown
nnoremap <leader>pm :Glow<CR>

" Template
nnoremap <Leader>ee oif err != nil {<CR>return nil, err<CR>}<CR><esc>kkI<esc>
nnoremap <Leader>ww ofunction wait(ms: number): Promise<void> {<CR>return new Promise(res => setTimeout(res, ms));<CR>}<esc>k=i{<CR>
nmap <leader>ii :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Function
fun! EmptyRegisters()
    let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [])
    endfor
endfun

" ES
com! W w

" Autogroup
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 40})
augroup END
augroup SWANDONO
    autocmd!
    autocmd BufWritePre * %s/\s\+$//e
augroup END

" Auto Command
autocmd TermEnter term://*toggleterm#*
      \ tnoremap <silent><C-k> <Cmd>exe v:count1 . "ToggleTerm"<CR>

autocmd BufReadPost,FileReadPost * normal zR
"autocmd BufWritePre *.ts,*.tsx,*.js,*.jsx,*.json,*.vue,*.css,*.html,*.yaml,*.yml,*.md Neoformat

""""""""""""""""""""""""
"" LUA
""""""""""""""""""""""""

" LSP
lua <<EOF
  -- Add additional capabilities supported by nvim-cmp
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
  -- Setup lspconfig.
  require("nvim-lsp-installer").setup {}
  local lspconfig = require('lspconfig')
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  local servers = { 'gopls', 'tsserver' }
  for _, lsp in pairs(servers) do
    lspconfig[lsp].setup {
        capabilities = capabilities,
        -- on_attach = on_attach,
        -- flags = lsp_flags,
    }
  end
EOF

" CMP
lua <<EOF
  local cmp = require'cmp'
  local lspkind = require('lspkind')
  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
       completion = cmp.config.window.bordered(),
       documentation = cmp.config.window.bordered(),
    },
    mapping = {
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<C-e>'] = cmp.mapping.abort(),
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
EOF

" Treesitter
lua <<EOF
  require'nvim-treesitter.configs'.setup {
    highlight = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
    textobjects = {
      enable = true
    },
    rainbow = {
      enable = true,
      extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
      max_file_lines = nil, -- Do not enable for files with more than n lines, int
    }
  }
  require'treesitter-context'.setup{
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
    patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
        default = {
            'class',
            'function',
            'method',
            -- 'for', -- These won't appear in the context
            -- 'while',
            -- 'if',
            -- 'switch',
            -- 'case',
        },
    },
    zindex = 20, -- The Z-index of the context window
  }
EOF

" Addon
lua <<EOF
  require("indent_blankline").setup {}
  require'nvim-tree'.setup{}
  require('nvim-cursorline').setup {
    cursorline = {
      enable = true,
      timeout = 0,
      number = false,
    },
    cursorword = {
      enable = false
    }
  }
  require("bufferline").setup{}
  require("toggleterm").setup{
    size = 50,
    shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
    persist_size = true,
    -- direction = 'vertical'
  }
EOF

" Dashboard
lua <<EOF
  require'alpha'.setup(require'alpha.themes.startify'.config)
EOF

" Git
lua <<EOF
  vim.o.updatetime = 300
  vim.o.incsearch = false
  vim.wo.signcolumn = 'yes'
  -- vgit
  require('vgit').setup()
  -- neogit
  local neogit = require('neogit')
  neogit.setup {}
EOF

" Lualine
lua <<EOF
   require('lualine').setup {
    options = {
      icons_enabled = true,
      theme = 'auto',
      component_separators = { left = 'ÓÇ±', right = 'ÓÇ≥'},
      section_separators = { left = 'ÓÇ∞', right = 'ÓÇ≤'},
      disabled_filetypes = {},
      always_divide_middle = true,
      globalstatus = false,
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
    },
    tabline = {},
    extensions = {}
  }
EOF

" Language
lua <<EOF
  require('go').setup{
    gopls_cmd = {'/Users/swandono/.local/share/nvim/lsp_servers/gopls/gopls'}
  }
EOF

" Other
lua <<EOF
  -- vim.opt.termguicolors = true
  require('Comment').setup()
  require("nvim-autopairs").setup {}
EOF

""""""""""""""""""""""""
"" END
""""""""""""""""""""""""

""""""""""""""""""""""""
"" SET
""""""""""""""""""""""""

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

set cmdheight=2

set updatetime=50

set shortmess+=c

" hello front end masters
set path+=**

" Nice menu when typing `:find *.py`
set wildmode=longest,list,full
set wildmenu

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

" Yes, I am a sneaky snek now
Plug 'ambv/black'

" Plebvim lsp Plugins
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }
Plug 'onsails/lspkind-nvim'
Plug 'nvim-lua/lsp_extensions.nvim'

" Diagram
Plug 'jbyuki/venn.nvim'

" Plug 'nvim-lua/completion-nvim'
Plug 'glepnir/lspsaga.nvim'
Plug 'simrat39/symbols-outline.nvim'
Plug 'tjdevries/nlua.nvim'
Plug 'tjdevries/lsp_extensions.nvim'

" Neovim Tree shitter
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

Plug 'rust-lang/rust.vim'
Plug 'darrikonn/vim-gofmt'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'
Plug 'mbbill/undotree'
Plug 'tpope/vim-dispatch'
Plug 'gruvbox-community/gruvbox'
Plug 'luisiacc/gruvbox-baby'
Plug 'tpope/vim-projectionist'
Plug 'tomlion/vim-solidity'

" telescope requirements...
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

Plug 'vim-conf-live/vimconflive2021-colorscheme'
Plug 'flazz/vim-colorschemes'
Plug 'chriskempson/base16-vim'

" vim-rfc!!
Plug 'mhinz/vim-rfc'

" prettier
Plug 'sbdchd/neoformat'

" should I try another status bar???
" Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
Plug 'nvim-lualine/lualine.nvim'
" Plug 'ryanoasis/vim-devicons'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'

" tab buffer
Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }

" tree
Plug 'kyazdani42/nvim-tree.lua'
Plug 'kyazdani42/nvim-web-devicons'

" toggle terminal
Plug 'akinsho/toggleterm.nvim', { 'tag': 'v1.*' }

" comment
Plug 'numToStr/Comment.nvim'

" line
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'yamatsum/nvim-cursorline'

" fold

call plug#end()


""""""""""""""""""""""""
"" MAP & OTHER's
""""""""""""""""""""""""

colorscheme gruvbox
highlight normal

" let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools', 'CodeLLDB' ]

" lua require'nvim-treesitter.configs'.setup { highlight = { enable = true }, incremental_selection = { enable = true }, textobjects = { enable = true }}
let g:vim_be_good_log_file = 1
let g:vim_apm_log = 1
" let g:airline_powerline_fonts = 1

if executable('rg')
    let g:rg_derive_root='true'
endif

let loaded_matchparen = 1
let mapleader = " "

nnoremap <leader>ps :lua require('telescope.builtin').live_grep()<CR>
nnoremap <leader>fs <cmd>lua require('telescope.builtin').find_files()<CR>
nnoremap <leader>ls :lua require('telescope.builtin').grep_string({ search = <C-r><C-w>})<CR>

nnoremap <silent> Q <nop>
nnoremap <silent> <C-f> :silent !tmux neww tmux-sessionizer<CR>
" Probably rename this, because its straight silly to be a worktree.

nnoremap <leader>u :UndotreeShow<CR>
nnoremap <leader>pv :Ex<CR>
nnoremap <Leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <Leader>] :vertical resize +5<CR>
nnoremap <Leader>[ :vertical resize -5<CR>
nnoremap <Leader>rp :resize 100<CR>
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

nnoremap <C-f>h :bp<CR>
nnoremap <C-f>l :bn<CR>
nnoremap <leader>bd :bd<CR>

nnoremap <leader>x :silent !chmod +x %<CR>

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

nnoremap <leader>y "*y
vnoremap <leader>y "*y

nnoremap <leader>p "*p
vnoremap <leader>p "*p
nnoremap <leader>P "*P
vnoremap <leader>P "*P

nnoremap <leader>d "_d
vnoremap <leader>d "_d

" lua
nnoremap <leader>vd :lua vim.lsp.buf.definition()<CR>
nnoremap <leader>vi :lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>vs :lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>vr :lua vim.lsp.buf.references() <CR>
nnoremap <leader>vn :lua vim.lsp.buf.rename() <CR>
nnoremap <leader>vh :lua vim.lsp.buf.hover()<CR>

" vim TODO
nmap <Leader>tu <Plug>BujoChecknormal
nmap <Leader>th <Plug>BujoAddnormal
let g:bujo#todo_file_path = $HOME . "/.cache/bujo"

" tree
nnoremap <C-n>l :NvimTreeRefresh<CR>
nnoremap <C-l> :NvimTreeToggle<CR>

" toggle terminal
nnoremap <silent><C-k> <Cmd>exe v:count1 . "ToggleTerm"<CR>
inoremap <silent><C-k> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>

" snip
snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<CR>
snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<CR>

" vim-fugitive
nnoremap <leader>gg :G<space>
nnoremap <leader>ga :G add<space>
nnoremap <leader>gb :G branch<CR>
nnoremap <leader>gc :G checkout<space>
nnoremap <leader>ge :G branch<space>
nnoremap <leader>gy :G commit<space>
nnoremap <leader>gt :G add .<CR>
nnoremap <leader>gl :G log<CR>
nnoremap <leader>gf :G fetch<CR>
nnoremap <leader>gpl :G pull<CR>
nnoremap <leader>gps :G push<CR>
nnoremap <leader>gd :G diff<CR>
nnoremap <leader>gi :G status<CR>
nnoremap <leader>gsh :G show<CR>
nnoremap <leader>gsw :G switch<space>

" function
nnoremap <Leader>ee oif err != nil {<CR>return nil, err<CR>}<CR><esc>kkI<esc>
nnoremap <Leader>ww ofunction wait(ms: number): Promise<void> {<CR>return new Promise(res => setTimeout(res, ms));<CR>}<esc>k=i{<CR>
nmap <leader>ii :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" close
inoremap <C-c> <esc>


fun! EmptyRegisters()
    let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [])
    endfor
endfun

" ES
com! W w

augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 40})
augroup END

augroup THE_PRIMEAGEN
    autocmd!
    autocmd BufWritePre *.lua Neoformat
    autocmd BufWritePre * %s/\s\+$//e
    autocmd BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{}
augroup END

autocmd TermEnter term://*toggleterm#*
      \ tnoremap <silent><c-k> <Cmd>exe v:count1 . "ToggleTerm"<CR>


""""""""""""""""""""""""
"" LUA
""""""""""""""""""""""""

lua <<EOF

  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
       completion = cmp.config.window.bordered(),
       documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      -- { name = 'vsnip' }, -- For vsnip users.
      { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
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
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig')['tsserver'].setup {
    capabilities = capabilities
  }

  -- Others
  -- vim.opt.termguicolors = true
  require("bufferline").setup{}
  require("toggleterm").setup{
    size = 50,
    shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
    persist_size = true,
    direction = 'vertical'
  }
  require("luasnip.loaders.from_vscode").lazy_load({paths = "~/.config/nvim/my_snips"})
  require('Comment').setup()

  -- Status and Icon
   require('lualine').setup {
    options = {
      icons_enabled = true,
      theme = 'auto',
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      disabled_filetypes = {},
      always_divide_middle = true,
      globalstatus = false,
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = {'filename'},
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
EOF


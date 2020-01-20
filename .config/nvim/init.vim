" Configuration file for neovim

set modelines=0

set encoding=utf-8

set background=light
set termguicolors


set backspace=indent,eol,start
set nostartofline       " Try to stay in the same column
set confirm             " Ask to save changes rather than fail

set autoindent		" always set autoindenting on
set viminfo='20,\"50	" read/write a .viminfo file, don't store more than
			" 50 lines of registers
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time

set secure              " Secure external vimrcs

set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching

set incsearch		" Incremental search
" Double esc to clear highlight of previous search
nmap <esc><esc> :silent! noh<cr>:<backspace>

set autowrite		" Automatically save before commands like :next and :make

set mouse=a		" Use mouse in all modes
set number		" Show line numbers
set shiftwidth=4	" Use indent depth of 4
set softtabstop=4	
set tabstop=8
set expandtab
set smarttab
set wrap		" Wrap long lines on screen
set linebreak		" Wrap at word boundaries
set foldclose=all	" Close folds automatically
set nofoldenable
set foldmethod=marker
set textwidth=79        " Wordwrap at this column
set formatoptions=tcl1  " Wrap, but not long lines, and not 1-letter words
set formatoptions+=q    " Allow formatting of comments
set formatoptions+=n    " Recognize numbered lists
set splitbelow          " Split new windows below current
set noerrorbells
set scrolloff=4         " Scroll before reaching screen edge
set cino=:0l1           " Do not indent case labels in switch or {} of case
set cino+=g0            " Do not indent C++ scope declarations
set cino+=t0            " Do not indent function return type
set cino+=(0w1          " Do not indent new lines inside parentheses
set cino+=m0            " Do not line up closing parentheses at SOL
set cino+=Ws            " Indent arguments in: func(\narg1,\narg2);
set cino+=j1            " Indent Java anonymous classes
set cino+=J1            " Indent JavaScript object declarations

"set ttyfast

set belloff=all

set wildmenu
set wildmode=longest:full,longest
set wildignore+=*.o,*~
"set wildoptions=pum

set nrformats-=octal

if has("autocmd")
    filetype plugin indent on
    filetype indent on
    filetype on
    au FileType ruby,eruby,yaml set ai sw=2 sts=2 et
    au FileType ruby,eruby set omnifunc=rubycomplete#Complete
    au FileType c set omnifunc=ccomplete#Complete
    au FileType css set omnifunc=csscomplete#CompleteCSS
    au FileType xml set omnifunc=xmlcomplete#CompleteTags
    au FileType html set omnifunc=htmlcomplete#CompleteTags
    au FileType javascript set omnifunc=javascriptcomplete#CompleteJS
    au FileType python set omnifunc=pythoncomplete#Complete
    au BufNewFile,BufRead *.pde set filetype=cpp
    au BufNewFile,BufRead *.rb set filetype=ruby
    au BufNewFile,BufRead *.c set filetype=c
    au BufNewFile,BufRead *.m set filetype=objc
    au BufNewFile,BufRead *.swift set filetype=swift

    au VimLeave * set guicursor=a:block-blinkon0
endif " has ("autocmd")

set completeopt+=menuone,noinsert,noselect,preview

let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_rails = 0
let g:ruby_minlines = 100

" Color scheme
syntax on
colorscheme arkkulight

" taglist.vim:
let Tlist_Close_On_Select = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Use_Right_Window = 1
let Tlist_File_Fold_Auto_Close = 0
let Tlist_Enable_Fold_Column = 0
let Tlist_Compact_Format = 1

" statusline:
set statusline=%n\ %<%t         " buffer number + filename (can be truncated)
set statusline+=%h%m%r%w        " flags
set statusline+=%=              " left/right separator
set statusline+=\ %{&fenc}      " file encoding
set statusline+=%15(%c,%l/%L%)  " cursor position
set statusline+=\ %6(0x%02B%)   " hex value of character under cursor
set laststatus=2                " always show status line

set sessionoptions-=options
set viewoptions-=options
set tabpagemax=50
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+

" Local leader
nnoremap <Space> <Nop>
let maplocalleader=" "

if exists('g:vscode')
    " Visual Studio Code neovim integration
else
    set timeoutlen=400
    set guioptions-=e

    " Remap C-A and C-E to be like other programs (line beginning/end)
    inoremap <C-A> <Home>
    inoremap <C-E> <End>

    " Map the unused C-Q to the old C-A
    inoremap <C-Q> <C-A>

    " Esc to exit terminal (with some delay), Esc Esc to send Esc
    tnoremap <Esc> <C-\><C-N>
    tnoremap <Esc><Esc> <Esc>

    " I use ^T as the tmux prefix, so let's appropriate ^B for the terminal
    tnoremap <C-B> <C-T>

    " vim-buffet
    let g:buffet_show_index = 1

    " \1 to \10 switch buffers (vim-buffet)
    nmap <Leader>1 <Plug>BuffetSwitch(1)
    nmap <Leader>2 <Plug>BuffetSwitch(2)
    nmap <Leader>3 <Plug>BuffetSwitch(3)
    nmap <Leader>4 <Plug>BuffetSwitch(4)
    nmap <Leader>5 <Plug>BuffetSwitch(5)
    nmap <Leader>6 <Plug>BuffetSwitch(6)
    nmap <Leader>7 <Plug>BuffetSwitch(7)
    nmap <Leader>8 <Plug>BuffetSwitch(8)
    nmap <Leader>9 <Plug>BuffetSwitch(9)
    nmap <Leader>10 <Plug>BuffetSwitch(10)

    " Space tab to open a new tab
    nmap <Leader><Tab> <Esc>:tabnew<CR>
    nmap <Leader><S-Tab> <Esc>:tabclose<CR>

    " Space 1 to 10 switch tabs
    nmap <LocalLeader>1 1gt
    nmap <LocalLeader>2 2gt
    nmap <LocalLeader>3 3gt
    nmap <LocalLeader>4 4gt
    nmap <LocalLeader>5 5gt
    nmap <LocalLeader>6 6gt
    nmap <LocalLeader>7 7gt
    nmap <LocalLeader>8 8gt
    nmap <LocalLeader>9 9gt
    nmap <LocalLeader>10 10gt
    nmap <LocalLeader><Tab> gt
    nmap <LocalLeader><S-Tab> gT

    " Tab to cycle buffers (with a hack to get rid of NERDTree)
    nmap <Tab> <Esc>:silent! NERDTreeClose<CR><Esc>:silent! bn<CR><Esc>
    nmap <S-Tab> <Esc>:silent! NERDTreeClose<CR><Esc>:silent! bp<CR><Esc>

    let g:buffet_always_show_tabline = 0
    let g:NERDTreeQuitOnOpen = 1
endif

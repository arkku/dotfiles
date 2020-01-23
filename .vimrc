" Configuration file for vim

if &term =~ ".*256col.*"
    set t_Co=256
    set t_Sf=[3%dm
    set t_Sb=[4%dm
    set t_AF=[3%p1%dm
    set t_AB=[4%p1%dm
    set t_8f=[38;2;%lu;%lu;%lum
    set t_8b=[48;2;%lu;%lu;%lum
    "set termguicolors
elseif &term =~ "xterm.*" || &term == "screen" || &term == "tmux" || &term =~ ".*-color.*"
    set t_Co=16
    set t_Sf=[3%dm
    set t_Sb=[4%dm
endif

if $BACKGROUND == 'dark'
    set background=dark
elseif $BACKGROUND == 'light'
    set background=light
elseif $COLORFGBG =~ '.*[,;][0-68]$'
    set background=dark
elseif $COLORFGBG =~ '.*[,;]\(7\|1[0-9]\)$'
    set background=light
endif

set ttymouse=xterm2

set nocompatible        " Use Vim defaults of 100% vi compatibility
set nohls               " Don't hilight search terms

set visualbell
set t_vb=
set belloff=all
silent! set encoding=utf-8
set backspace=indent,eol,start
set nostartofline       " Try to stay in the same column

set modelines=0
set autoindent          " always set autoindenting on
set viminfo='20,\"100   " read/write a .viminfo file
set ruler               " show the cursor position all the time
set whichwrap=b,s,[,]   " Allow arrows to wrap over lines in insert mode

set secure              " Secure external vimrcs

set showcmd             " Show (partial) command in status line.
set showmatch           " Show matching brackets.
set ignorecase          " Do case insensitive matching

set incsearch           " Incremental search
silent! set inccommand=nosplit  " Incremental substitute

set confirm             " Ask to save changes rather than fail
set autowrite           " Automatically save before commands like :next and :make
silent! set autowriteall
silent! set autoread

set mouse=a             " Use mouse in all modes
set number              " Show line numbers
set shiftwidth=4        " Use indent depth of 4
set softtabstop=4
set tabstop=8
set expandtab
set smarttab
set wrap                " Wrap long lines on screen
set linebreak           " Wrap at word boundaries
set foldclose=all       " Close folds automatically
set nofoldenable
set foldmethod=marker
set textwidth=79        " Wordwrap at this column
set formatoptions=cl1
set formatoptions+=q    " Allow formatting of comments
set formatoptions+=n    " Recognize numbered lists
silent! set formatoptions+=p    " Don't break one word alone on a line
set formatoptions+=j    " Join comment lines
set formatoptions+=r    " Auto-insert comment leader on return
"set formatoptions+=a    " Automatically reformat paragraphs
set formatoptions-=t
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

set wildmenu
set wildmode=longest:full,longest
set wildignore+=*.o,*~
silent! set wildoptions=pum

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
    au BufNewFile,BufRead *.swift set filetype=swift
    au BufNewFile,BufRead *.inc set filetype=asm
endif " has ("autocmd")

set completeopt+=menuone,noinsert,noselect,preview

let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_rails = 0
let g:ruby_minlines = 100

" Color scheme:
syntax on

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
"set statusline+=\ %<%y
set statusline+=%=              " left/right separator
set statusline+=\ %<%{exists('g:loaded_fugitive')?FugitiveStatusline():''}
set statusline+=\ %<%y\ [%{&fenc}] " file encoding
set statusline+=%15(%c,%l/%L%)  " cursor position
set statusline+=\ %<%6(0x%02B%) " hex value of character under cursor
set laststatus=2                " always show status line

set sessionoptions-=options
set viewoptions-=options
set tabpagemax=50
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+

" Local leader
nnoremap <Space> <Nop>
let maplocalleader=" "

silent! set virtualedit=onemore,block

colorscheme arkku

set ttimeout
set ttimeoutlen=100

" ctrl arrows
noremap <C-Left> B
noremap <C-Right> W
noremap <C-Up> <Home>
noremap <C-Down> <End>
inoremap <C-Left> <C-O>b
inoremap <C-Right> <C-O>w
inoremap <C-Up> <Home>
inoremap <C-Down> <End>

" alt arrows
noremap <A-Left> b
noremap <A-Right> w
noremap <A-Up> <Home>
noremap <A-Down> <End>
inoremap <A-Left> <C-O>b
inoremap <A-Right> <C-O>w
inoremap <A-Up> <Home>
inoremap <A-Down> <End>

" arrows
noremap <Esc>[D <Left>
noremap <Esc>[C <Right>
noremap <Esc>[A <Up>
noremap <Esc>[B <Down>
inoremap <Esc>[D <Left>
inoremap <Esc>[C <Right>
inoremap <Esc>[A <Up>
inoremap <Esc>[B <Down>
noremap <Esc>OD <Left>
noremap <Esc>OC <Right>
noremap <Esc>OA <Up>
noremap <Esc>OB <Down>
inoremap <Esc>OD <Left>
inoremap <Esc>OC <Right>
inoremap <Esc>OA <Up>
inoremap <Esc>OB <Down>

" ctrl arrows
noremap <Esc>[5D B
noremap <Esc>[5C W
noremap <Esc>[1;5D B
noremap <Esc>[1;5C W
noremap <Esc>[5A <Home>
noremap <Esc>[5B <End>
noremap <Esc>[1;5A <Home>
noremap <Esc>[1;5B <End>
inoremap <Esc>[5D <C-O>b
inoremap <Esc>[5C <C-O>w
inoremap <Esc>[1;5D <C-O>b
inoremap <Esc>[1;5C <C-O>w
inoremap <Esc>[5A <Home>
inoremap <Esc>[5B <End>
inoremap <Esc>[1;5A <Home>
inoremap <Esc>[1;5B <End>

" alt arrows
noremap <Esc>[1;3D b
noremap <Esc>[1;3C w
noremap <Esc><Esc>[D b
noremap <Esc><Esc>[C w
noremap <Esc>[1;3A <Home>
noremap <Esc>[1;3B <End>
noremap <Esc><Esc>[A <Home>
noremap <Esc><Esc>[B <End>
inoremap <Esc>[1;3D <C-O>b
inoremap <Esc>[1;3C <C-O>w
inoremap <Esc><Esc>[D <C-O>b
inoremap <Esc><Esc>[C <C-O>w
inoremap <Esc>[1;3A <Home>
inoremap <Esc>[1;3B <End>
inoremap <Esc><Esc>[A <Home>
inoremap <Esc><Esc>[B <End>

" cmd arrows
noremap <Esc>[1;4D <Home>
noremap <Esc>[1;4C <End>
noremap <Esc>[1;4A <PageUp>
noremap <Esc>[1;4B <PageDown>
inoremap <Esc>[1;4D <Home>
inoremap <Esc>[1;4C <End>
inoremap <Esc>[1;4A <PageUp>
inoremap <Esc>[1;4B <PageDown>

if 1
    set timeoutlen=400
    set guioptions-=e

    set switchbuf=useopen,split
    silent! set switchbuf+=usetab

    " alt backspace
    inoremap <Esc><C-H> <C-U>
    inoremap <Esc><C-?> <C-U>

    " Map some keys to be more like other programs
    inoremap <C-BS> <C-W>
    inoremap <C-Del> <C-O>dw
    inoremap <M-Left> <Home>
    inoremap <M-Right> <End>

    inoremap <C-A> <Home>
    inoremap <expr> <C-E> pumvisible() ? "\<C-E>" : "\<End>"
    inoremap <C-B> <C-E>
    " ^- map the unused C-B to the old C-E, even the mnemonic makes more sense

    cnoremap <C-A> <Home>
    cnoremap <C-B> <C-A>

    " Map the unused C-Q to the old C-A
    inoremap <C-Q> <C-A>

    " open a new buffer and edit a file in it with 'open'
    cabbrev open enew\|e
    cabbrev vopen vnew\|e
    cabbrev hopen new\|e

    " strip trailing whitespace
    cabbrev stws %s/\s\+$//e

    " \1 to \0 switch buffers (vim-buffet)
    nmap <Leader>1 <Plug>BuffetSwitch(1)
    nmap <Leader>2 <Plug>BuffetSwitch(2)
    nmap <Leader>3 <Plug>BuffetSwitch(3)
    nmap <Leader>4 <Plug>BuffetSwitch(4)
    nmap <Leader>5 <Plug>BuffetSwitch(5)
    nmap <Leader>6 <Plug>BuffetSwitch(6)
    nmap <Leader>7 <Plug>BuffetSwitch(7)
    nmap <Leader>8 <Plug>BuffetSwitch(8)
    nmap <Leader>9 <Plug>BuffetSwitch(9)
    nmap <Leader>0 <Plug>BuffetSwitch(10)
    nnoremap <Leader>q <Esc>:bd<CR>
    nnoremap <Leader>x <Esc>:bw!<CR>

    " Quickfix
    nnoremap <Leader>f <Esc>:copen<CR>
    nnoremap <Leader>F <Esc>:ccl<CR>
    nnoremap <Leader>w <Esc>:cw<CR>

    " Space tab to open a new tab
    nnoremap <Leader><Tab> <Esc>:tabnew<CR>
    nnoremap <Leader><S-Tab> <Esc>:tabclose<CR>

    " Space 1 to 0 switch tabs
    nnoremap <LocalLeader>1 1gt
    nnoremap <LocalLeader>2 2gt
    nnoremap <LocalLeader>3 3gt
    nnoremap <LocalLeader>4 4gt
    nnoremap <LocalLeader>5 5gt
    nnoremap <LocalLeader>6 6gt
    nnoremap <LocalLeader>7 7gt
    nnoremap <LocalLeader>8 8gt
    nnoremap <LocalLeader>9 9gt
    nnoremap <LocalLeader>0 10gt
    nnoremap <LocalLeader>q <Esc>:tabclose<CR>
    nnoremap <LocalLeader>x <Esc>:tabclose!<CR>
    nnoremap <LocalLeader><Tab> gt
    nnoremap <LocalLeader><S-Tab> gT

    " Esc to exit terminal (with some delay), Esc Esc to send Esc
    tnoremap <Esc> <C-\><C-N>
    tnoremap <Esc><Esc> <Esc>

    " I use ^T as the tmux prefix, so let's appropriate ^B for the terminal
    tnoremap <C-B> <C-T>

    " Tab to cycle buffers (with a hack to get rid of NERDTree)
    nnoremap <Tab> <Esc>:silent! NERDTreeClose<CR><Esc>:silent! bn<CR><Esc>
    nnoremap <S-Tab> <Esc>:silent! NERDTreeClose<CR><Esc>:silent! bp<CR><Esc>

    let g:buffet_show_index = 1
    let g:buffet_always_show_tabline = 0
    let g:NERDTreeQuitOnOpen = 1
endif

if has("autocmd")
    "au FileType u,swift,cc,cs,cxx,cpp,h,hpp,java,php,python,ruby,sh,bash,zsh,eiffel,asm,elixir,erlang,awk,json,javascript,html,css,scss,xml,xhtml,yaml,dart,kotlin,rust,d autocmd BufWritePre <buffer> %s/\s\+$//e
    " Wrap text only in text files
    au FileType text,markdown,textile setlocal formatoptions+=t
endif

" Paste in insert mode with C-B, toggling paste mode (mnemonic: "Baste")
set pastetoggle=<F10>
if empty(mapcheck('<C-B>', 'i'))
    inoremap <C-B> <F10><C-R>+<F10>
endif

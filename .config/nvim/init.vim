" Configuration file for neovim

" Try to determine the terminal background color
if $BACKGROUND == 'dark'
    set background=dark
elseif $BACKGROUND == 'light'
    set background=light
elseif $COLORFGBG =~ '.*[,;][0-68]$'
    set background=dark
elseif $COLORFGBG =~ '.*[,;]\(7\|1[0-9]\)$'
    set background=light
elseif $TERM =~ '.*\(linux\|ansi\|vt[0-9]\|dos\|bsd\|mach\|console\|con[0-9]\).*'
    set background=dark
else
    set background=light
endif

if ($TERM =~ '.*-256color.*' && ($TERM_PROGRAM != "Apple_Terminal" || !empty($TMUX))) || !empty($TERMGUICOLORS)
    set termguicolors
    set colorcolumn=+1
    set list
endif

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

syntax on
colorscheme arkku

" alt backspace
noremap! <Esc><C-H> <C-U>
noremap! <Esc><C-?> <C-U>

" ctrl arrows
noremap <C-Left> B
noremap <C-Right> W
noremap <C-Up> <Home>
noremap <C-Down> <End>
inoremap <C-Left> <C-O>b
inoremap <C-Right> <C-O>w
noremap! <C-Up> <Home>
noremap! <C-Down> <End>

" alt arrows
noremap <A-Left> b
noremap <A-Right> w
noremap <A-Up> <Home>
noremap <A-Down> <End>
inoremap <A-Left> <C-O>b
inoremap <A-Right> <C-O>w
cnoremap <A-Left> <S-Left>
cnoremap <A-Right> <S-Right>
noremap! <A-Up> <Home>
noremap! <A-Down> <End>
inoremap <M-Left> <C-O>b
inoremap <M-Right> <C-O>w
cnoremap <M-Left> <S-Left>
cnoremap <M-Right> <S-Right>

noremap! <C-A> <Home>
" Map the unused C-Q to the old C-A
noremap! <C-Q> <C-A>

" Map C-E to end of line or close any open pop-up menu
inoremap <expr> <C-E> pumvisible() ? "\<C-E>" : "\<End>"
inoremap <C-B> <C-E>
" ^- map the unused C-B to the old C-E, even the mnemonic makes more sense
"
" strip trailing whitespace
cabbrev stws %s/\s\+$//e

if exists('g:vscode')
    " Visual Studio Code neovim integration
else
    set timeoutlen=400
    set guioptions-=e

    set switchbuf=useopen,split
    silent! set switchbuf+=usetab

    noremap! <C-BS> <C-W>
    inoremap <C-Del> <C-O>dw

    " open a new buffer and edit a file in it with 'open'
    cabbrev open enew\|e
    cabbrev vopen vnew\|e
    cabbrev hopen new\|e

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

    " Shortcuts to open a split terminal
    nnoremap <Leader>t <Esc>:split term://$SHELL
    nnoremap <Leader>T <Esc>:split term://

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

" Double-Esc to clear highlight of previous search
nnoremap <Esc><Esc> :silent! noh<CR>:<BS><Esc>

if has("autocmd")
    "au FileType u,swift,cc,cs,cxx,cpp,h,hpp,java,php,python,ruby,sh,bash,zsh,eiffel,asm,elixir,erlang,awk,json,javascript,html,css,scss,xml,xhtml,yaml,dart,kotlin,rust,d autocmd BufWritePre <buffer> %s/\s\+$//e
    " Wrap text only in text files
    au FileType text,markdown,textile setlocal formatoptions+=t
endif

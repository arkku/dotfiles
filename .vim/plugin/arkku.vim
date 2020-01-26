" arkku.vim: .vimrc/init.vim shared settings

if exists('g:loaded_arkku_shared')
    finish
else
    let g:loaded_arkku_shared='yes'
endif

silent! set encoding=utf-8

syntax on

set belloff=all
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
set expandtab           " Use spaces, not tabs, for indentation
set smarttab            " Use backspace to go back a tabstop
set shiftround          " Round indent to shift widths
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

" statusline:
set statusline=%n\ %<%t         " buffer number + filename (can be truncated)
set statusline+=%h%m%r%w        " flags
"set statusline+=\ %<%y
set statusline+=%=              " left/right separator
silent! set statusline+=\ %<%{exists('g:loaded_fugitive')?FugitiveStatusline():''}
set statusline+=\ %<%y\ [%{&fenc}] " file encoding
set statusline+=%15(%c,%l/%L%)  " cursor position
set statusline+=\ %<%6(0x%02B%) " hex value of character under cursor
set laststatus=2                " always show status line

set sessionoptions-=options
set viewoptions-=options
set tabpagemax=50
silent! set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+

set nrformats-=octal

silent! set omnifunc=syntaxcomplete#Complete
silent! set completeopt+=menuone,noinsert,noselect,preview

if &compatible
    finish
endif

"set ttyfast

set wildmenu
set wildmode=longest:full,longest
set wildignore+=*.o,*~,*.bin,*.exe,*.com,*.a,*.so,*.dll
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*
silent! set wildoptions=pum

if has("autocmd")
    " Recognize file types and apply the relevant plugins and settings
    filetype on
    filetype plugin on
    filetype indent on

    " Use my settings for various programming languages instead of filetype
    au FileType ruby,eruby,yaml setlocal ai sw=2 sts=2 et
    au FileType c,swift,cc,cs,cxx,cpp,h,hpp,java,python,sh,bash,zsh,eiffel,elixir,erlang,awk,javascript,dart,kotlin,rust,d,vim setlocal ai sw=4 sts=4 et

    " Fix formatting of lists in markdown
    au FileType text,markdown setlocal formatlistpat=^\\s*\\d\\+[.\)]\\s\\+\\\|^\\s*[*+~-]\\s\\+\\\|^\\(\\\|[*#]\\)\\[^[^\\]]\\+\\]:\\s | setlocal comments=n:> | setlocal formatoptions+=tcn | setlocal indentexpr= autoindent smartindent

    au FileType liquid if exists('b:liquid_subtype') && b:liquid_subtype == 'markdown' | setlocal formatlistpat=^\\s*\\d\\+[.\)]\\s\\+\\\|^\\s*[*+~-]\\s\\+\\\|^\\(\\\|[*#]\\)\\[^[^\\]]\\+\\]:\\s | setlocal comments=n:> | setlocal formatoptions+=tcn | setlocal indentexpr= autoindent smartindent | endif

    au BufNewFile,BufRead *.pde set filetype=cpp
    au BufNewFile,BufRead *.swift set filetype=swift
    au BufNewFile,BufRead *.inc set filetype=asm
endif

let g:markdown_minlines=100

if !exists('g:markdown_fenced_languages')
    if exists('*getcompletion')
        let g:markdown_fenced_languages=[]

        if index(getcompletion('zsh', 'filetype'), 'zsh') >= 0
            call add(g:markdown_fenced_languages, 'zsh=sh')
        else
            call add(g:markdown_fenced_languages, 'bash=sh')
        endif

        for pl in [ 'c', 'ruby', 'swift', 'html', 'javascript', 'python', 'make', 'yaml', 'json', 'cs', 'css', 'cpp', 'rust', 'kotlin', 'dart', 'haskell', 'scheme', 'lisp', 'ada', 'eiffel', 'clojure', 'latex' ]
            if index(getcompletion(pl, 'filetype'), pl) >= 0
                call add(g:markdown_fenced_languages, pl)
            endif
        endfor
    else
        let g:markdown_fenced_languages=[ 'c', 'bash=sh' ]
    endif
endif

" Allow YAML frontmatter (e.g., Jekyll)
let g:vim_markdown_frontmatter=1

" Enable ~~ strikethrough
let g:vim_markdown_strikethrough=1

" Allow LaTeX match with $ and $$
let g:vim_markdown_math=1

" Allow links to markdown files work without extensions
let g:vim_markdown_no_extensions_in_markdown=1

let g:vim_markdown_new_list_item_indent=0
let g:vim_markdown_auto_insert_bullets=0

let g:rubycomplete_classes_in_global=1
let g:rubycomplete_buffer_loading=1
let g:rubycomplete_rails=0
let g:ruby_minlines=100

silent! set virtualedit=onemore,block

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
" Make p in visual mode paste over the selection without yanking it
vnoremap p "_dP

inoremap <C-_> <C-R>=

"if empty(mapcheck('<C-S>', 'i'))
"endif

if !exists('g:vscode')
    set timeoutlen=400
    set guioptions-=e

    set switchbuf=useopen,split
    silent! set switchbuf+=usetab

    nnoremap [oa <Esc>:set formatoptions +=a<CR>
    nnoremap ]oa <Esc>:set formatoptions -=a<CR>
    nnoremap [ot <Esc>:set formatoptions +=t<CR>
    nnoremap ]ot <Esc>:set formatoptions -=t<CR>

    noremap! <C-BS> <C-W>
    inoremap <C-Del> <C-O>dw

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
    nnoremap <Leader>t <Esc>:split term://$SHELL<CR>A
    nnoremap <Leader>T <Esc>:split term://

    " Esc to exit terminal (with some delay), Esc Esc to send Esc
    tnoremap <Esc> <C-\><C-N>
    tnoremap <Esc><Esc> <Esc>

    " I use ^T as the tmux prefix, so let's appropriate ^B for the terminal
    tnoremap <C-B> <C-T>

    " Paste from system clipboard in insert mode with C-B (mnemonic: Baste)
    if !has('nvim') && empty(mapcheck('<C-B>', 'i'))
        " Note that currently the mapcheck fails since we map C-B above, but
        " I'm just leaving this here for future reference
        set pastetoggle=<F10>
        inoremap <C-B> <F10><C-R>+<F10>
    endif

    " Tab to cycle buffers (with a hack to get rid of NERDTree)
    nnoremap <Tab> <Esc>:silent! NERDTreeClose<CR><Esc>:silent! bn<CR><Esc>
    nnoremap <S-Tab> <Esc>:silent! NERDTreeClose<CR><Esc>:silent! bp<CR><Esc>

    let g:buffet_show_index=1
    let g:buffet_always_show_tabline=0
    let g:NERDTreeQuitOnOpen=1
    let g:ctrlp_by_filename=0
    let g:ctrlp_working_path_mode='ra'

    " taglist.vim:
    let g:Tlist_Close_On_Select=1
    let g:Tlist_GainFocus_On_ToggleOpen=1
    let g:Tlist_Exit_OnlyWindow=1
    let g:Tlist_Use_Right_Window=1
    let g:Tlist_File_Fold_Auto_Close=0
    let g:Tlist_Enable_Fold_Column=0
    let g:Tlist_Compact_Format=1
endif

" Fallback if there is no fzf
nmap <LocalLeader>z <C-P>

if executable('fzf')
    " Add fzf if installed
    if !empty(glob(expand("~/.fzf")))
        set runtimepath+=~/.fzf
    elseif !empty(glob("/usr/local/opt/fzf"))
        set runtimepath+=/usr/local/opt/fzf
    elseif !exits('g:loaded_fzf') && !empty(glob("/usr/share/doc/fzf/examples/plugin/fzf.vim"))
        set runtimepath+=/usr/share/doc/fzf/examples
    endif

    runtime! plugin/fzf.vim

    if exists('g:loaded_fzf')
        if executable('ag')
            " Space z to open FZF with Ag
            nnoremap <LocalLeader>z <Esc>:silent! NERDTREEClose<CR>:call fzf#run(fzf#wrap({'source': 'ag -l --nocolor --depth 5 -g 2>/dev/null ""'}))<CR>
        else
            " Space z to open FZF
            nnoremap <LocalLeader>z <Esc>:silent! NERDTREEClose<CR>:FZF<CR>
        endif
    endif
endif

if executable('ag')
    " Use Ag over Grep
    set grepprg=ag\ --nogroup\ --nocolor
    let g:ackprg='ag --vimgrep'

    " Use Ag in CtrlP for listing files
    let g:ctrlp_user_command='ag %s -l --nocolor --depth 3 -g 2>/dev/null ""'
    let g:ctrlp_use_caching=0
endif

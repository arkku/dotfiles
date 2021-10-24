" arkku.vim: .vimrc/init.vim shared settings

if exists('g:loaded_arkku_shared')
    finish
else
    let g:loaded_arkku_shared='yes'
endif

silent! set encoding=utf-8

syntax on

silent! set belloff=all
set backspace=indent,eol,start
set nostartofline       " Try to stay in the same column

silent! set diffopt+=vertical
"silent! set diffopt+=indent-heuristic

set modelines=0
set autoindent          " always set autoindenting on
set viminfo='20,\"100   " read/write a .viminfo file
set ruler               " show the cursor position all the time
set whichwrap=b,s,[,]   " Allow arrows to wrap over lines in insert mode

set secure              " Secure external vimrcs

set showcmd             " Show (partial) command in status line.
set cmdheight=2         " Increase the command-line height
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
set nofoldenable
set foldclose=all       " Close folds automatically
set foldopen+=insert
set foldmethod=indent
set foldlevelstart=0
set foldnestmax=4
set textwidth=79        " Wordwrap at this column
set formatoptions=cl1
set formatoptions+=q    " Allow formatting of comments
set formatoptions+=n    " Recognize numbered lists
silent! set formatoptions+=p    " Don't break one word alone on a line
silent! set formatoptions+=j    " Join comment lines
set formatoptions+=r    " Auto-insert comment leader on return
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

set updatetime=521      " Update swap file more often
set hidden              " Hide, rather than unload, abandoned buffers
silent! set shortmess+=c        " Don't show completion menu info messages
silent! set signcolumn=yes      " Always show the sign column

" Return in insert mode: accept autocompletion (endwise- and closer-compatible)
let g:endwise_no_mappings=1
imap <silent><expr> <Plug>CloserClose ""
imap <silent><expr> <Plug>DiscretionaryEnd ""
imap <silent><expr> <Plug>AlwaysEnd ""
imap <C-X><CR> <CR><Plug>AlwaysEnd
imap <silent><expr> <CR> (pumvisible() ? "\<C-Y>" : "\<CR>\<Plug>DiscretionaryEnd\<Plug>CloserClose")

let g:SuperTabDefaultCompletionType="<C-N>"
let g:SuperTabContextDefaultCompletionType="<C-N>"
let g:SuperTabLongestEnhanced=1

function! GitStatuslineBranch()
    if exists('g:loaded_fugitive')
        let l:fstatus = fugitive#statusline()
        if len(l:fstatus) < 3
            return ''
        endif
        let l:branch = split(l:fstatus, '[()]')
        if len(l:branch) > 2
            return '[' . join(l:branch[1:-2], '/') . '] '
        elseif len(l:branch) == 2
            return '[' . l:branch[1] . '] '
        elseif len(l:branch) == 1
            return l:branch[0] . ' '
        endif
    endif
    return ''
endfunction

function! SyntaxErrorsStatus()
    let status = ''
    if exists('g:loaded_syntastic_plugin')
        let synstatus = SyntasticStatuslineFlag()
        if !empty(synstatus)
            let status = ' ' . synstatus
        endif
    endif
    if exists('g:coc_enabled') && g:coc_enabled
        let info = get(b:, 'coc_diagnostic_info', {})
        if !empty(info)
            let msgs = []
            if get(info, 'error', 0)
                call add(msgs, 'E' . info['error'])
            endif
            if get(info, 'warning', 0)
                call add(msgs, 'W' . info['warning'])
            endif
            let status = ' ' . join(msgs, ' ')
        endif
    endif
    if exists('g:ale_enabled') && g:ale_enabled
        let counts = ale#statusline#Count(bufnr(''))
        let errcount = counts.error + counts.style_error
        let warncount = counts.total - errcount
        let alestatus = ''

        if errcount > 0
            let alestatus = printf("Err: %d", errcount)
        endif

        if warncount > 0
            let alestatus = alestatus . printf("%sWarn: %d", empty(alestatus) ? "" : " ", warncount)
        endif

        if !empty(alestatus)
            let status = " [" . alestatus . "]" . status
        endif
    endif
    return status . " "
endfunction

" Show the file encoding if it is not the same as internal (UTF-8)
function! EncodingStatusline()
    if &fileencoding != &encoding
        return '[' . &fileencoding . '] '
    endif
    return ''
endfunction

function! FilenameMiddleTruncated(maxlen)
    let str = expand('%:t')
    if empty(str) || len(str) <= a:maxlen || a:maxlen < 2
        return str
    endif
    let halflen = a:maxlen / 2
    if halflen * 2 < a:maxlen
        return str[0:halflen] . '…' . str[-halflen:]
    else
        return str[0:halflen - 1] . '…' . str[-halflen:]
    endif
endfunction

" statusline:
set statusline=%n\ %{FilenameMiddleTruncated(36)}
set statusline+=%h%m%r%w        " flags
set statusline+=\ %{EncodingStatusline()}
silent! set statusline+=%<%{GitStatuslineBranch()}
set statusline+=%=              " left/right separator
silent! set statusline+=%<%{SyntaxErrorsStatus()}
set statusline+=%20(%c,%l/%L\ %P%)  " cursor position
set statusline+=\ %6(0x%02B%) " hex value of character under cursor
set laststatus=2              " always show status line

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

silent! set ttyfast

set wildmenu
set wildmode=longest:full,full
set wildignore+=*.o,*.bin,*.exe,*.com,*.a,*.so,*.dll,*.obj
silent! set wildoptions=pum
silent! set wildignorecase

if has("autocmd")
    " Recognize file types and apply the relevant plugins and settings
    filetype on
    filetype plugin on
    filetype indent on

    " Use my settings for various programming languages instead of filetype
    au FileType ruby,eruby,yaml,json setlocal ai sw=2 sts=2 ts=4 et
    au FileType c,swift,cc,cs,cxx,cpp,h,hpp,java,python,sh,bash,zsh,eiffel,elixir,erlang,awk,javascript,dart,kotlin,rust,d,vim,typescript setlocal ai sw=4 ts=4 sts=4 et
    au FileType swift,objcpp,kotlin,dart,haskell let b:closer = 1 | let b:closer_flags = '([{'

    " Fix formatting of lists in markdown
    au FileType text,markdown setlocal formatlistpat=^\\s*\\d\\+[.\)]\\s\\+\\\|^\\s*[*+~-]\\s\\+\\\|^\\(\\\|[*#]\\)\\[^[^\\]]\\+\\]:\\s | setlocal comments=n:> | setlocal formatoptions+=tcn | setlocal indentexpr= autoindent smartindent

    " Set markdown comments to HTML and use headers for dlist
    au FileType markdown setlocal commentstring=<!--%s--> | setlocal define=^#\\+\\s*

    " Use man headers for dlist
    au FileType man setlocal define=^[A-Z0-9].*

    au FileType liquid if exists('b:liquid_subtype') && b:liquid_subtype == 'markdown' | setlocal formatlistpat=^\\s*\\d\\+[.\)]\\s\\+\\\|^\\s*[*+~-]\\s\\+\\\|^\\(\\\|[*#]\\)\\[^[^\\]]\\+\\]:\\s | setlocal comments=n:> | setlocal formatoptions+=tcn | setlocal indentexpr= autoindent smartindent | setlocal define=^#\\+\\s* | endif
    au FileType liquid setlocal commentstring={%\ comment\ %}%s{%\ endcomment\ %}

    au BufNewFile,BufRead *.pde set filetype=cpp
    au BufNewFile,BufRead *.swift set filetype=swift
    au BufNewFile,BufRead *.inc set filetype=asm

    " Might as well use the MARK: comments for dlist
    au FileType swift setlocal define=^\s*/[/*]*\\s*MARK:[\ -]*
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

let g:syntastic_mode_map = {
    \ "mode": "active",
    \ "active_filetypes": ["zsh","bash","sh"],
    \ "passive_filetypes": [] }

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_signs = 1
let g:syntastic_aggregate_errors = 1

let g:rubycomplete_classes_in_global=1
let g:rubycomplete_buffer_loading=1
let g:rubycomplete_rails=0
let g:ruby_minlines=100

silent! set virtualedit=onemore,block

" ^? as backspace
noremap! <C-?> <C-H>

" alt backspace
noremap! <Esc><C-H> <C-U>
noremap! <Esc><C-?> <C-U>

" ctrl arrows
noremap <C-Left> <Home>
noremap <C-Right> <End>
noremap <C-Up> g<Up>
noremap <C-Down> g<Down>
noremap! <C-Left> <Home>
noremap! <C-Right> <End>
inoremap <C-Up> <C-O>g<Up>
inoremap <C-Down> <C-O>g<Down>
cnoremap <C-Up> <C-U>
cnoremap <C-Down> <C-D>

" alt arrows
noremap <A-Left> b
noremap <A-Right> w
noremap <A-Up> <Home>
noremap <A-Down> <End>
cnoremap <A-Left> <S-Left>
cnoremap <A-Right> <S-Right>
inoremap <A-Left> <C-O>b
inoremap <A-Right> <C-O>w
noremap! <A-Up> <Home>
noremap! <A-Down> <End>

noremap! <A-BS> <C-W>

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

inoremap <C-_> <C-R>=printf("%",)<Left><Left><Left>
cnoremap <C-_> <C-R>=findfile("",";")<Left><Left><Left><Left><Left><Left>

"if empty(mapcheck('<C-S>', 'i'))
"endif

nnoremap [oy <Esc>:

if !exists('g:vscode')
    set timeoutlen=400
    set guioptions-=e

    set switchbuf=useopen,split
    silent! set switchbuf+=usetab

    " Since Tab/C-I is mapped to other things, use C-Q for the old C-I
    " (note that on Dvorak C-O and C-Q are vertically adjacent)
    nnoremap <C-Q> <C-I>

    nnoremap [oa <Esc>:set formatoptions +=a<CR>
    nnoremap ]oa <Esc>:set formatoptions -=a<CR>
    nnoremap [ot <Esc>:set formatoptions +=t<CR>
    nnoremap ]ot <Esc>:set formatoptions -=t<CR>

    noremap! <C-BS> <C-W>
    inoremap <C-Del> <C-O>dw

    nmap <silent> <C-N> :Lexplore<CR>

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
    nnoremap <Leader>f <Esc>:cw<CR>
    nnoremap <Leader>F <Esc>:ccl<CR>

    " Location List
    nnoremap <Leader>l <Esc>:lopen<CR>
    nnoremap <Leader>L <Esc>:lclose<CR>

    " Syntastic
    nnoremap <Leader>s <Esc>:silent! SyntasticCheck<CR>:silent! SyntasticSetLoclist<CR>:silent! Errors<CR>
    nnoremap <Leader>S <Esc>:silent! SyntasticReset<CR>

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

    if has('nvim')
        au TermOpen * setlocal nonumber norelativenumber nospell nofoldenable nolist signcolumn=no

        function! BDeleteBang(...)
            bdelete!
        endfunction

        " On nvim, replace the \t terminal with a toggleable one
        function! OpenTerminal(identifier)
            let identifier = 't_' . a:identifier

            let window = bufwinnr(identifier)
            if window > 0
                " Already visible, close it
                :exe window . "wincmd c"
                return
            endif

            keepalt bo new
            setlocal filetype=terminal
            setlocal bufhidden=hide
            setlocal noswapfile nobuflisted nomodified signcolumn=no
            setlocal nolist nospell nonumber norelativenumber nofoldenable

            let buffer = bufexists(identifier)
            if buffer > 0
                " Open the existing buffer in the new split
                :exe "buffer " identifier
            else
                " Create the terminal
                let options = {'on_exit': 'BDeleteBang'}
                call termopen($SHELL, options)
                :exe "f " identifier
            endif
            startinsert
        endfunction

        "nnoremap <C-T> :call OpenTerminal('console')<CR>
        nnoremap <Leader>t :call OpenTerminal('console')<CR>

        let g:yoinkSavePersistently=1
        silent! set shada=!,'100,<50,s10,h

        " Paste from system clipboard (in nvim it generally just works to paste
        " directly, so this kind of inverts the behaviour since Ctrl-R is
        " affected by formatting) - mnemonic 'Baste'
        inoremap <C-B> <C-R>+
    endif

    let g:yoinkSwapClampAtEnds=0
    let g:yoinkSyncSystemClipboardOnFocus=0
    let g:yoinkMoveCursorToEndOfPaste=1
    let g:yoinkIncludeDeleteOperations=1
    " nnoremap <Plug>(YoinkYankPreserveCursorPosition) y
    " xnoremap <Plug>(YoinkYankPreserveCursorPosition) y
    " nmap y <Plug>(YoinkYankPreserveCursorPosition)
    " xmap y <Plug>(YoinkYankPreserveCursorPosition)
    nnoremap <Plug>(YoinkPaste_p) p
    nnoremap <Plug>(YoinkPaste_P) P
    nnoremap <Plug>(YoinkPostPasteSwapBack) j
    nnoremap <Plug>(YoinkPostPasteSwapForward) k
    nmap p <Plug>(YoinkPaste_p)
    nmap P <Plug>(YoinkPaste_P)

    " C-J and C-K immediately after put cycle history (with yoink.vim)
    nmap <C-J> <Plug>(YoinkPostPasteSwapBack)
    nmap <C-K> <Plug>(YoinkPostPasteSwapForward)

    " ]w and [w to jump to next/prev warning/error (coc, ale, llist)
    nmap <silent><expr> ]w (exists('coc_enabled') && coc_enabled && !(exists('b:coc_enabled') && !b:coc_enabled)) ? "\<Plug>(coc-diagnostic-next)" : (exists('ale_enabled') && ale_enabled) ? "\<Plug>(ale_next_wrap)" : ":lnext\<CR>"
    nmap <silent><expr> [w (exists('coc_enabled') && coc_enabled && !(exists('b:coc_enabled') && !b:coc_enabled)) ? "\<Plug>(coc-diagnostic-prev)" : (exists('ale_enabled') && ale_enabled) ? "\<Plug>(ale_previous_wrap)" : ":lprevious\<CR>"

    " space + w and space + W to open/close list of diagnostics (or location list)
    nmap <silent><expr> <LocalLeader>w (exists('coc_enabled') && coc_enabled) ? ":CocList diagnostics<CR>" : ":lopen\<CR>"
    nmap <silent><expr> <LocalLeader>W (exists('coc_enabled') && coc_enabled) ? ":CocList diagnostics<CR>" : ":lclose\<CR>"

    function! ShowDocumentationForWordUnderCursor()
        if exists('g:coc_enabled') && g:coc_enabled && (!exists('b:coc_enabled') || b:coc_enabled) && CocAction('doHover')
            return
        elseif exists('g:ale_enabled') && g:ale_enabled && (!exists('b:ale_enabled') || b:ale_enabled)
            execute "ALEHover"
        else
            execute "normal! K"
        endif
    endfunction

    " show documentation for word under the cursor
    nnoremap <silent> K :call ShowDocumentationForWordUnderCursor()<CR>

    let g:ale_sign_error = '!!'
    let g:ale_sign_warning = '??'

    " Esc to exit terminal (with some delay), Esc Esc to send Esc
    silent! tnoremap <Esc> <C-\><C-N>
    silent! tnoremap <Esc><Esc> <Esc>

    " Paste from system clipboard in insert mode with C-B (mnemonic: Baste)
    if !has('nvim') && empty(mapcheck('<C-B>', 'i'))
        " Note that currently the mapcheck fails since we map C-B above, but
        " I'm just leaving this here for future reference
        set pastetoggle=<F10>
        inoremap <C-B> <F10><C-R>+<F10>
    endif
endif

" Always reset the chgwin to accommodate both :Lexplore and :Explore
au FileType netrw au BufCreate <buffer> let g:netrw_chgwin=-1 | setlocal nobuflisted bufhidden=wipe

let g:netrw_liststyle=3
let g:netrw_winsize=30
let g:netrw_altv=1
"let g:netrw_altfile=1
let g:netrw_banner=0
let g:netrw_sizestyle='H'
"let g:netrw_usetab=1
let g:netrw_special_syntax=1
"let g:netrw_browse_split=0
"let g:netrw_preview=1

let g:buffet_show_index=1
let g:buffet_always_show_tabline=0

let g:NERDTreeQuitOnOpen=1

let g:ctrlp_by_filename=0
let g:ctrlp_working_path_mode='ra'

" Open tag search with space+t
nnoremap <LocalLeader>t <Esc>:CtrlPTag<CR>
nnoremap <LocalLeader>T <Esc>:CtrlPTag<CR>

" Use '.tags' instead of 'tags' as the tagfile default name
set tags^=./.git/tags;
set tags^=./.tags;
set tags^=.tags
let g:gutentags_ctags_tagfile='.tags'

" gutentags.vim
let g:gutentags_generate_on_missing=0
let g:gutentags_generate_on_new=0

" taglist.vim:
let g:Tlist_Close_On_Select=1
let g:Tlist_GainFocus_On_ToggleOpen=1
let g:Tlist_Exit_OnlyWindow=1
let g:Tlist_Use_Right_Window=1
let g:Tlist_File_Fold_Auto_Close=0
let g:Tlist_Enable_Fold_Column=0
let g:Tlist_Compact_Format=1

" Fallback if there is no fzf
nmap <LocalLeader>z <C-P>

" cd to current file's directory
command! CD lcd %:p:h
command! CDC cd %:p:h

if executable('fzf')
    " Add fzf if installed
    if !empty(glob(expand("~/.fzf")))
        set runtimepath+=~/.fzf
    elseif !empty(glob("/usr/local/opt/fzf"))
        set runtimepath+=/usr/local/opt/fzf
    elseif !exists('g:loaded_fzf') && !empty(glob("/usr/share/doc/fzf/examples/plugin/fzf.vim"))
        set runtimepath+=/usr/share/doc/fzf/examples
    endif

    runtime! plugin/fzf.vim

    if exists('g:loaded_fzf')
        " Space z to open fuzzy file finder
        if executable('fd')
            nnoremap <LocalLeader>z <Esc>:silent! NERDTREEClose<CR>:call fzf#run(fzf#wrap({'source': 'fd -c never -d 5 -- . 2>/dev/null'}))<CR>
        elseif executable('rg')
            nnoremap <LocalLeader>z <Esc>:silent! NERDTREEClose<CR>:call fzf#run(fzf#wrap({'source': 'rg --color never --max-depth 4 -l -- ""'}))<CR>
        elseif executable('ag')
            nnoremap <LocalLeader>z <Esc>:silent! NERDTREEClose<CR>:call fzf#run(fzf#wrap({'source': 'ag -l --nocolor --depth 4 -- "" 2>/dev/null'}))<CR>
        else
            " Space z to open FZF
            nnoremap <LocalLeader>z <Esc>:silent! NERDTREEClose<CR>:FZF<CR>
        endif
    endif

    nnoremap <Leader>/ <Esc>:Lines<CR>
    nnoremap <LocalLeader>/ <Esc>:BLines<CR>
    nnoremap <LocalLeader>h <Esc>:History<CR>

    " If fzf is installed, override space+t (defined above) for fzf tag search
    nnoremap <LocalLeader>t <Esc>:Tags<CR>
endif

if executable('fd')
    " Use fd in CtrlP for listing files
    let g:ctrlp_user_command='fd -c never -d 5 -- . %s 2>/dev/null'
    let g:ctrlp_use_caching=0
elseif executable('rg')
    " Use ripgrep in CtrlP for listing files
    let g:ctrlp_user_command='rg --color never -l --max-depth 3 -- "" %s'
    let g:ctrlp_use_caching=0
elseif executable('ag')
    " Use Ag in CtrlP for listing files
    let g:ctrlp_user_command='ag --nocolor -l --depth 3 -- "" %s 2>/dev/null'
    let g:ctrlp_use_caching=0
endif

if executable('rg')
    " Use ripgrep over grep
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --multiline-dotall\ --hidden
    set grepformat=%f:%l:%c:%m,%f:%l:%m
    let g:ackprg='rg --vimgrep --no-heading'
elseif executable('ag')
    " Use Ag over grep
    set grepprg=ag\ --vimgrep
    set grepformat=%f:%l:%c:%m
    let g:ackprg='ag --vimgrep'
endif

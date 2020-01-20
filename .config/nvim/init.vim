" Configuration file for neovim

set encoding=utf-8

set background=light
set termguicolors

set modelines=0

set backspace=indent,eol,start	" more powerful backspacing
set nostartofline       " Try to stay in the same column
set confirm             " Ask to save changes rather than fail

set autoindent		" always set autoindenting on
set viminfo='20,\"50	" read/write a .viminfo file, don't store more than
			" 50 lines of registers
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time

" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

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

" surround.vim:
let g:surround_65 = "<a href=\"\">\r</a>"   " yssA to wrap sentence as link
let g:surround_66 = "{\n\t\r\n}"            " SB in V mode to wrap as a block
let g:surround_68 = "do\n\t\r\nend"         " cs{D to change {} into do/end


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

    au VimLeave * set guicursor=a:block-blinkon0
endif " has ("autocmd")

set completeopt+=menuone,noinsert,noselect,preview

let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_rails = 0
let g:ruby_minlines = 100


if has("autocmd")
    " VSB to wrap selection in a block ({}, begin/end) for the current language:
    au FileType ruby,eruby let surround_66 = "begin\n\t\r\nend"
    au FileType c,java,objc,cpp,javascript,go,cs,sh,bash let surround_66 = "{\n\t\r\n}"
    au FileType swift let surround_66 = "do {\n\t\r\n}"
    au FileType lua let surround_66 = "do\n\t\r\nend"
    au FileType html let surround_66 = "<div>\n\t\r\n</div>"

    " VSE to wrap selection in exception handling for the current language:
    au FileType ruby,eruby let surround_69 = "begin\n\t\r\nrescue Exception => e\nend"
    au FileType eiffel let surround_69 = "do\n\t\r\nrescue\nend"
    au FileType ada let surround_69 = "begin\n\t\r\nexception\nend;"
    au FileType java let surround_69 = "try {\n\t\r\n} catch (Exception e) {\n}"
    au FileType objc let surround_69 = "@try {\n\t\r\n} @catch (NSException *e) {\n}"
    au FileType cs let surround_69 = "try {\n\t\r\n} catch (System.Exception e) {\n}"
    au FileType javascript let surround_69 = "try {\n\t\r\n} catch (err) {\n}"
    au FileType cpp let surround_69 = "try {\n\t\r\n} catch (const std::exception& e) {\n}"
    au FileType swift let surround_69 = "do {\n\t\r\n} catch {\n}"
    au FileType python let surround_69 = "try:\n\t\r\nexcept Exception as e:\n"
    au FileType erlang let surround_69 = "try\n\t\r\ncatch\nend"

    " VSF to wrap selection in the equivalent of 'if false then ... endif':
    au FileType c,objc,cpp let surround_70 = "#if 0\n\r\n#endif"
    au FileType swift let surround_70 = "#if false\n\r\n#endif"
    au FileType ruby,eruby let surround_70 = "=begin\n\t\r\n=end"
    au FileType java,javascript,go,cs let surround_70 = "if (false) {\n\t\r\n}"
    au FileType python let surround_70 = "if False:\n\t\r\n"
    au FileType eiffel let surround_70 = "if False then\n\t\r\nend"
    au FileType lua let surround_70 = "if false then\n\t\r\nend"
    au FileType sh,bash let surround_70 = "if false; then\n\t\r\nfi"

    " Prefer new-style comments in C-like languages
    au FileType c,objc,cpp,swift setlocal commentstring=//%s
end

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

" Color scheme
syntax on
colorscheme arkkulight

if exists('g:vscode')
    " Visual Studio Code neovim integration
else
    set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
    set tabpagemax=50

    set guioptions-=e

    map <C-n> :NERDTreeToggle<CR>

    " Allow Esc to cancel pop-up menus for completion
    inoremap <expr> <Esc>   pumvisible() ? "\<C-e>" : "\<Esc>"

    " Fix some keys for various terminals
    map <Esc>OA <Up>
    map <Esc>OB <Down>
    map <Esc>OC <Right>
    map <Esc>OD <Left>
    map <Esc>[5A <C-Up>
    map <Esc>[5B <C-Down>
    map <Esc>[5C <C-Right>
    map <Esc>[5D <C-Left>
    map <Esc>O5A <C-Up>
    map <Esc>O5B <C-Down>
    map <Esc>O5C <C-Right>
    map <Esc>O5D <C-Left>
    map <Esc>0a <C-Up>
    map <Esc>0b <C-Down>
    map <Esc>0c <C-Right>
    map <Esc>0d <C-Left>
    map <Esc>[3;5~ <C-Del>
    map <Esc><Esc>[A <M-Up>
    map <Esc><Esc>[B <M-Down>
    map <Esc><Esc>[C <M-Right>
    map <Esc><Esc>[D <M-Left>
    map <Esc>[[A <M-Up>
    map <Esc>[[B <M-Down>
    map <Esc>[[C <M-Right>
    map <Esc>[[D <M-Left>
    map! <Esc>OA <Up>
    map! <Esc>OB <Down>
    map! <Esc>OC <Right>
    map! <Esc>OD <Left>
    map! <Esc>[5A <C-Up>
    map! <Esc>[5B <C-Down>
    map! <Esc>[5C <C-Right>
    map! <Esc>[5D <C-Left>
    map! <Esc>O5A <C-Up>
    map! <Esc>O5B <C-Down>
    map! <Esc>O5C <C-Right>
    map! <Esc>O5D <C-Left>
    map! <Esc>0a <C-Up>
    map! <Esc>0b <C-Down>
    map! <Esc>0c <C-Right>
    map! <Esc>0d <C-Left>
    map! <Esc>[3;5~ <C-Del>
    map! <Esc><Esc>[A <M-Up>
    map! <Esc><Esc>[B <M-Down>
    map! <Esc><Esc>[C <M-Right>
    map! <Esc><Esc>[D <M-Left>
    map! <Esc>[[A <M-Up>
    map! <Esc>[[B <M-Down>
    map! <Esc>[[C <M-Right>
    map! <Esc>[[D <M-Left>

    " Map some keys to be more like other programs
    map! <M-Left> <Home>
    map! <M-Right> <End>
    map <M-Left> <Home>
    map <M-Right> <End>
    map! <C-BS> <C-W>
    imap <C-Del> <C-O>dw
    imap <C-A> <Home>
    imap <C-E> <End>

    " Local leader
    nnoremap <Space> <Nop>
    let maplocalleader=" "
endif

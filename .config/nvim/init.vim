" Configuration file for Neovim

"let g:ale_completion_enabled = 1

" Use the normal Vim installation path since we have it anyway
set runtimepath+=~/.vim,~/.vim/after
set packpath+=~/.vim

" Note that that the settings shared between Vim and Neovim have been moved to
" the file ~/.vim/plugin/arkku.vim

" Decide whether we should set 'background' manually
let s:should_set_bg = 1

if $TERM =~# '^\(xterm-kitty\|xterm-ghostty\)'
    " These terminals should be able to tell their BG color
    let s:should_set_bg = 0
elseif $TERM =~# '^tmux' && !empty($TMUX)
    let s:tmux_theme = trim(system("tmux display -p '#{client_theme}' 2>/dev/null || true"))
    if s:tmux_theme ==# 'light' || s:tmux_theme ==# 'dark'
        " tmux returns a client_theme
        let s:should_set_bg = 0
    endif
endif

if s:should_set_bg
    if $BACKGROUND ==# 'dark'
        set background=dark
    elseif $BACKGROUND ==# 'light'
        set background=light
    elseif $COLORFGBG =~# '.*[,;][0-68]$'
        set background=dark
    elseif $COLORFGBG =~# '.*[,;]\(7\|1[0-9]\)$'
        set background=light
    elseif $TERM =~# '.*\(linux\|ansi\|vt[0-9]\|dos\|bsd\|mach\|console\|con[0-9]\).*'
        set background=dark
    else
        set background=light
    endif
endif


if ($TERM =~ '.*-256color.*' && ($TERM_PROGRAM != "Apple_Terminal" || !empty($TMUX))) || !empty($TERMGUICOLORS)
    set termguicolors
    set colorcolumn=+1
    set list
endif

" Double-Esc to clear highlight of previous search
nnoremap <Esc><Esc> <Esc>:silent! noh<CR>:<BS><Esc>

" Check for updates on focus
au FocusGained * :checktime

" Local leader
nnoremap <Space> <Nop>
let maplocalleader=" "

colorscheme arkku

" Fix clipboard over ssh/mosh
if getenv('SSH_CONNECTION') != v:null || getenv('TMUX') != v:null
  let g:clipboard = {
    \ 'name': 'clipcopy',
    \ 'copy': {
    \   '+': [expand('~/bin/clipcopy')],
    \   '*': [expand('~/bin/clipcopy')],
    \ },
    \ 'paste': {
    \   '+': [expand('~/bin/clippaste')],
    \   '*': [expand('~/bin/clippaste')],
    \ },
    \ 'cache_enabled': 0,
    \ }
endif

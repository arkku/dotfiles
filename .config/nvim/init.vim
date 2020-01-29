" Configuration file for Neovim

"let g:ale_completion_enabled = 1

" Use the normal Vim installation path since we have it anyway
set runtimepath+=~/.vim,~/.vim/after
set packpath+=~/.vim

" Note that that the settings shared between Vim and Neovim have been moved to
" the file ~/.vim/plugin/arkku.vim

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

" Double-Esc to clear highlight of previous search
nnoremap <Esc><Esc> <Esc>:silent! noh<CR>:<BS><Esc>

" Check for updates on focus
au FocusGained * :checktime

" Local leader
nnoremap <Space> <Nop>
let maplocalleader=" "

colorscheme arkku

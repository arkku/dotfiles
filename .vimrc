" Configuration file for vim

" Note that that the settings shared between Vim and Neovim have been moved to
" the file ~/.vim/plugin/arkku.vim

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

" Local leader
nnoremap <Space> <Nop>
let maplocalleader=" "

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
noremap <Esc>[1;5D <Home>
noremap <Esc>[1;5C <End>
noremap <Esc>[5A <Home>
noremap <Esc>[5B <End>
noremap <Esc>[1;5A g<Up>
noremap <Esc>[1;5B g<Down>
inoremap <Esc>[5D <C-O>b
inoremap <Esc>[5C <C-O>w
cnoremap <Esc>[5D <S-Left>
cnoremap <Esc>[5C <S-Right>
noremap! <Esc>[1;5D <Home>
noremap! <Esc>[1;5C <End>
noremap! <Esc>[5A <Home>
noremap! <Esc>[5B <End>
inoremap <Esc>[1;5A <C-O>g<Up>
inoremap <Esc>[1;5B <C-O>g<Down>
cnoremap <Esc>[1;5A <S-Up>
cnoremap <Esc>[1;5B <S-Down>

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
noremap! <Esc>[1;3A <Home>
noremap! <Esc>[1;3B <End>
noremap! <Esc><Esc>[A <Home>
noremap! <Esc><Esc>[B <End>
cnoremap <Esc>[1;3D <S-Left>
cnoremap <Esc>[1;3C <S-Right>
cnoremap <Esc><Esc>[D <S-Left>
cnoremap <Esc><Esc>[C <S-Right>

" cmd arrows
noremap <Esc>[1;4D <Home>
noremap <Esc>[1;4C <End>
noremap <Esc>[1;4A <PageUp>
noremap <Esc>[1;4B <PageDown>
noremap! <Esc>[1;4D <Home>
noremap! <Esc>[1;4C <End>
noremap! <Esc>[1;4A <PageUp>
noremap! <Esc>[1;4B <PageDown>

set ttimeout
set ttimeoutlen=100

colorscheme arkku

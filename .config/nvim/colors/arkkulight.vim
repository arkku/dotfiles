" A color scheme for Neovim by Kimmo Kulovesi <https://arkku.dev/>.

hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name = "arkkulight"

hi clear Normal
hi Normal term=none cterm=none gui=none guifg=#222222 guibg=#ffffff
hi NormalNC term=none cterm=none gui=none guifg=#333333
hi Terminal term=none cterm=none gui=none guifg=#000000 guibg=#ffffff

hi SpecialKey term=reverse cterm=bold ctermfg=cyan gui=bold guifg=#0066cc guibg=#f0f0ff
hi WhiteSpace term=standout cterm=none ctermfg=lightcyan gui=none guifg=#c0f0f0
hi Conceal term=underline cterm=none ctermfg=gray gui=none guifg=#cccccc

" Syntax highlighting
hi Comment term=underline cterm=none ctermfg=gray gui=none guifg=#cccccc

hi Constant term=none cterm=none ctermfg=darkgreen gui=none guifg=#0066cc
hi Boolean term=none cterm=none ctermfg=darkgreen gui=none guifg=#0066cc
hi Number term=none cterm=none ctermfg=darkgreen gui=none guifg=#0099aa
hi Float term=none cterm=none ctermfg=darkgreen gui=none guifg=#0099aa
hi Character term=none cterm=none ctermfg=darkgreen gui=none guifg=#0041a3
hi String term=none cterm=none ctermfg=brown gui=none guifg=#dd6666

hi Identifier term=none cterm=none ctermfg=blue gui=none guifg=#003366
hi clear Function
hi Function term=none cterm=none gui=none guifg=#000000

hi clear Conditional
hi clear Repeat
hi clear Exception
hi clear Statement
hi Statement term=none cterm=bold gui=bold guifg=#333333
hi Label term=bold cterm=bold ctermfg=darkblue gui=bold guifg=#0066cc
hi clear Operator
hi clear Keyword
hi Operator term=none cterm=none gui=none guifg=#000000
hi Keyword term=bold cterm=bold gui=bold guifg=#000000

hi clear PreCondit
hi PreProc term=none cterm=bold ctermfg=darkgray gui=bold guifg=#006600
hi Include term=none cterm=bold ctermfg=darkgray gui=none guifg=#006600
hi Macro term=none cterm=bold ctermfg=darkgray gui=none guifg=#006600

hi clear Structure
hi clear Typedef
hi clear StorageClass
hi clear Type
hi Type term=none cterm=bold gui=bold guifg=#000000

hi clear SpecialChar
hi clear Delimiter
hi clear SpecialComment
hi clear Debug
hi Special term=bold cterm=none ctermfg=darkcyan gui=none guifg=#0099aa
hi Delimiter term=bold cterm=none ctermfg=darkcyan gui=none guifg=#63a35c
hi Tag term=bold cterm=none ctermfg=darkcyan gui=none guifg=#63a35c

hi clear Underlined
hi Underlined term=underline cterm=underline gui=underline

hi Ignore term=none cterm=none ctermfg=white gui=none guifg=#fefefe

hi Error term=reverse cterm=none ctermfg=white ctermbg=darkred gui=none guifg=#ffffff guibg=#990000

hi Todo term=standout cterm=none ctermfg=white ctermbg=darkgreen gui=none guifg=#003300 guibg=#99ffdd

" Search and Selection
hi IncSearch term=reverse cterm=reverse gui=none guibg=#ffe07a
hi Search term=reverse cterm=reverse gui=none guibg=#fff0e0

hi clear Visual
hi Visual term=reverse cterm=reverse gui=none guibg=#e3f8ff
hi VisualNOS term=reverse cterm=reverse gui=reverse

hi MatchParen term=reverse ctermbg=cyan guibg=#d9f1ff

" UI
hi StatusLine term=bold,reverse cterm=reverse gui=reverse guifg=#0281ff guibg=#ffffff
hi StatusLineNC term=bold,reverse cterm=reverse gui=reverse guifg=#0281ff guibg=#99ccff
hi TabLine term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#cccccc guifg=#403f53
hi TabLineSel term=bold,reverse cterm=underline,bold ctermfg=white ctermbg=blue gui=underline guibg=#fafafa guifg=#000000
hi TabLineFill term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#222222 guifg=#666666
hi VertSplit term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#222222 guifg=#666666

hi WarningMsg term=standout cterm=bold ctermfg=darkred gui=bold guifg=#cc9900
hi ErrorMsg term=standout cterm=none ctermfg=white ctermbg=darkred gui=none guifg=#ffffff guibg=#990000

hi ModeMsg term=bold cterm=bold ctermfg=brown gui=bold guifg=#3399cc
hi MoreMsg term=bold cterm=bold ctermfg=lightblue gui=bold guifg=#009966
hi Question term=bold cterm=bold ctermfg=lightblue gui=bold guifg=#009966
hi Title term=bold cterm=bold ctermfg=yellow gui=bold guifg=#ff9933

hi LineNr term=reverse cterm=none ctermbg=black ctermfg=gray gui=none guibg=#222222 guifg=#888888
hi CursorLineNr term=reverse cterm=none ctermbg=black ctermfg=white gui=none guibg=#000000 guifg=#bbbbbb
hi CursorLine guibg=#f5f5f5
hi CursorColumn guibg=#fefefe
hi NonText term=bold cterm=none ctermfg=gray gui=none guifg=#666666 guibg=#f0f0f0

hi Folded term=reverse cterm=none ctermfg=blue ctermbg=gray gui=none guifg=#0099cc guibg=#f0f0f0
hi FoldColumn term=reverse cterm=none ctermbg=black ctermfg=cyan gui=none guibg=#222222 guifg=#cccccc

hi clear SignColumn
hi link SignColumn LineNr
"hi SignColumn term=reverse cterm=none ctermbg=black ctermfg=cyan gui=none guibg=#222222 guifg=#99eeff

hi ColorColumn term=reverse cterm=none ctermbg=lightgray gui=none guibg=#ffffe0

" Menu
hi clear Directory
hi Directory term=bold cterm=bold gui=bold guifg=#000000

hi PMenu term=reverse cterm=none ctermfg=gray ctermbg=darkblue gui=none guibg=#0281ff guifg=#eeeeee
hi PMenuSel term=bold cterm=bold ctermfg=black ctermbg=gray gui=bold guifg=#000066 guibg=#f0f0ee
hi WildMenu term=standout cterm=bold,reverse gui=bold guifg=#000066 guibg=#f0f0ee
hi PMenuSBar term=reverse cterm=none ctermfg=gray ctermbg=darkblue gui=none guibg=#0281ff guifg=#cccccc
hi PMenuThumb term=reverse,bold cterm=none ctermfg=gray ctermbg=darkred gui=none guibg=#660000 guifg=#ffffff

" Diff
hi DiffAdd term=bold ctermfg=darkgreen ctermbg=lightgray guibg=#d9ffde
hi DiffDelete term=reverse ctermfg=darkred ctermbg=lightgray guibg=#d9f0ff
hi DiffChange term=bold ctermfg=brown ctermbg=lightgray guibg=#eaeaea
hi DiffText term=reverse cterm=underline ctermbg=gray gui=none guibg=#f7f3d6

" Terminal
let g:terminal_color_0 = '#000000'
let g:terminal_color_1 = '#660000'
let g:terminal_color_2 = '#003300'
let g:terminal_color_3 = '#cc6600'
let g:terminal_color_4 = '#000099'
let g:terminal_color_5 = '#660066'
let g:terminal_color_6 = '#6699cc'
let g:terminal_color_7 = '#bbbbbb'
let g:terminal_color_8 = '#333333'
let g:terminal_color_9 = '#993300'
let g:terminal_color_10 = '#006600'
let g:terminal_color_11 = '#ff9900'
let g:terminal_color_12 = '#0066cc'
let g:terminal_color_13 = '#9966cc'
let g:terminal_color_14 = '#0099ff'
let g:terminal_color_15 = '#ffffff'

let g:gitgutter_override_sign_column_highlight = 0
hi GitGutterAdd term=standout ctermfg=lightgreen ctermbg=black guibg=#222222 guifg=#00cc33
hi GitGutterChange term=standout ctermfg=cyan ctermbg=black guibg=#222222 guifg=#0099ff
hi GitGutterDelete term=standout ctermfg=lightred ctermbg=black guibg=#222222 guifg=#ff3300
hi GitGutterChangeDelete term=standout ctermfg=magenta ctermbg=black guibg=#222222 guifg=#ff0066
hi GitGutterChangeDeleteInvisible ctermfg=black ctermbg=black guibg=#222222 guifg=#222222
hi GitGutterChangeInvisible ctermfg=black ctermbg=black guibg=#222222 guifg=#222222
hi GitGutterDeleteInvisible ctermfg=black ctermbg=black guibg=#222222 guifg=#222222
hi GitGutterAddInvisible ctermfg=black ctermbg=black guibg=#222222 guifg=#222222

" vim-buffet
function! g:BuffetSetCustomColors()
    hi! BuffetCurrentBuffer term=bold,reverse cterm=bold ctermfg=white ctermbg=blue  gui=underline guibg=#fafafa guifg=#000000
    hi! BuffetBuffer term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#cccccc guifg=#403f53
    hi! BuffetActiveBuffer term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#cccccc guifg=#403f53
    hi! BuffetTrunc term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#222222 guifg=#666666
    hi! BuffetTab term=reverse cterm=none ctermfg=red ctermbg=blue gui=none guibg=#cccccc guifg=#666666
    hi! BuffetModCurrentBuffer term=bold,reverse cterm=bold ctermfg=white ctermbg=blue  gui=underline guibg=#fafafa guifg=#000000
    hi! BuffetModBuffer term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#cccccc guifg=#403f53
    hi! BuffetModActiveBuffer term=reverse cterm=none ctermfg=lightblue ctermbg=blue gui=none guibg=#cccccc guifg=#403f53
endfunction

if !empty($TMUX) || !empty($TERM_PROGRAM)
    hi SpellBad gui=none guibg=#ffddcc
    hi SpellCap gui=none guibg=#ffddff
    hi SpellRare gui=none
    hi SpellLocal gui=none
endif

hi! link vimVar Identifier
hi! link vimGroup Identifier
hi! link vimMap Identifier
hi! link vimFunc Function
hi! link vimFunction Function
hi! link vimUserFunc Function
hi! link helpSpecial Special
hi! link vimSet Normal
hi! link vimSetEqual Normal
hi! link vimCommand Keyword
hi! link vimCmdSep Operator
hi! link vimExecute Statement
hi! link vimPattern Special
hi! link vimSubstRep String
hi! link vimSubstRange Special
hi! link vimRange Special

hi! link helpOption Special
hi! link helpExample String
hi! link helpVim Keyword
hi! link helpHyperTextJump Label
hi! link helpHyperTextEntry Tag
hi! link helpCommand PreProc
hi! link helpFunction Title
hi! link helpOperator Character
hi! link helpNote Todo


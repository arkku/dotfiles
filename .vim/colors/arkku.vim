" colors/arkku.vim: A color scheme for Vim and Neovim
"
" This theme supports both light and dark backgrounds. One design goal
" is that it remains readable even in the basic EGA/VGA text mode
" terminal.
"
" Use `set background=light` and `set background=dark` according to your
" background color, or vim may do this automatically.
"
" By Kimmo Kulovesi <https://arkku.dev/> 2001-2020

hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name = "arkku"

hi clear Normal
hi clear IncSearch
hi clear Search

hi Normal term=none cterm=none gui=none guifg=#222222 guibg=#ffffff
hi NormalNC term=none cterm=none gui=none guifg=#333333
hi Terminal term=none cterm=none gui=none guifg=#000000 guibg=#ffffff

hi SpecialKey term=reverse cterm=bold ctermfg=cyan gui=bold guifg=#0066cc guibg=#f0f0ff
hi WhiteSpace term=standout cterm=none ctermfg=lightcyan gui=none guifg=#c0f0f0
hi Conceal term=underline cterm=none ctermfg=gray gui=none guifg=#cccccc

" Syntax highlighting
hi clear SpecialComment
hi Comment term=underline cterm=none ctermfg=gray gui=none guifg=#cccccc
hi SpecialComment term=underline cterm=none ctermfg=darkcyan gui=none guifg=#669999

hi Constant term=none cterm=none ctermfg=blue gui=none guifg=#0066cc
hi Boolean term=none cterm=none ctermfg=blue gui=none guifg=#0066cc
hi Number term=none cterm=none ctermfg=blue gui=none guifg=#006699
hi Float term=none cterm=none ctermfg=blue gui=none guifg=#006699
hi Character term=none cterm=none ctermfg=blue gui=none guifg=#0041a3
hi String term=none cterm=none ctermfg=brown gui=none guifg=#884466

hi Identifier term=none cterm=none ctermfg=darkblue gui=none guifg=#003366
hi clear Function
hi Function term=none cterm=none gui=none guifg=#26474B

hi clear Conditional
hi clear Repeat
hi clear Exception
hi clear Statement
hi Statement term=none cterm=bold gui=bold guifg=#333333
hi Label term=bold cterm=bold ctermfg=darkblue gui=bold guifg=#006699
hi clear Operator
hi clear Keyword
hi Operator term=none cterm=none gui=none guifg=#000000
hi Keyword term=bold cterm=bold gui=bold guifg=#000000

hi clear PreCondit
hi PreProc term=none cterm=bold ctermfg=green gui=bold guifg=#009933
hi Include term=none cterm=bold ctermfg=darkgreen gui=none guifg=#006633
hi Macro term=none cterm=bold ctermfg=darkgreen gui=none guifg=#006633

hi clear Structure
hi clear Typedef
hi clear StorageClass
hi Structure term=none cterm=bold gui=bold guifg=#000000
hi Typedef term=none cterm=bold gui=bold guifg=#3F6E74
hi StorageClass term=none cterm=bold gui=bold guifg=#000000
hi clear Type
hi Type term=none cterm=bold gui=bold guifg=#0B4F79

hi clear SpecialChar
hi clear Delimiter
hi clear Debug
hi Special term=bold cterm=none ctermfg=darkcyan gui=none guifg=#0099aa
hi Delimiter term=bold cterm=none ctermfg=green gui=none guifg=#63a35c
hi Tag term=bold cterm=none ctermfg=green gui=none guifg=#63a35c

hi clear Underlined
hi Underlined term=underline cterm=underline gui=underline

hi Ignore term=none cterm=none ctermfg=white gui=none guifg=#fefefe

hi Error term=reverse cterm=none ctermfg=white ctermbg=darkred gui=none guifg=#ffffff guibg=#990000

hi Todo term=standout cterm=none ctermfg=white ctermbg=darkgreen gui=none guifg=#003300 guibg=#99ffdd

" Search and Selection
hi IncSearch term=reverse cterm=reverse,underline gui=reverse guifg=#ffe07a guibg=#222222
hi Search term=reverse cterm=reverse gui=none guibg=#fff0e0

hi clear Visual
hi Visual term=reverse cterm=reverse gui=none guibg=#e3f8ff
hi VisualNOS term=reverse cterm=reverse gui=reverse

hi MatchParen term=reverse ctermbg=lightcyan guibg=#d9f1ff

" UI
hi StatusLine term=bold,reverse cterm=reverse gui=reverse guifg=#0281ff guibg=#ffffff
hi StatusLineNC term=bold,reverse cterm=reverse gui=reverse guifg=#3399cc guibg=#bbccff
hi TabLine term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#cccccc guifg=#403f53
hi TabLineSel term=bold,reverse cterm=underline,bold ctermfg=white ctermbg=blue gui=underline guibg=#fafafa guifg=#000000
hi TabLineFill term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#222222 guifg=#666666
hi VertSplit term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#222222 guifg=#666666

hi WarningMsg term=standout cterm=bold ctermfg=red gui=bold guifg=#cc9900
hi ErrorMsg term=standout cterm=none ctermfg=white ctermbg=darkred gui=none guifg=#ffffff guibg=#990000

hi ModeMsg term=bold cterm=bold ctermfg=brown gui=bold guifg=#3399cc
hi MoreMsg term=bold cterm=bold ctermfg=blue gui=bold guifg=#009966
hi Question term=bold cterm=bold ctermfg=magenta gui=bold guifg=#009966
hi Title term=bold cterm=bold ctermfg=yellow gui=bold guifg=#ff9933

hi LineNr term=reverse cterm=none ctermbg=black ctermfg=gray gui=none guibg=#222222 guifg=#666666
hi CursorLineNr term=reverse cterm=none ctermbg=black ctermfg=white gui=none guibg=#222222 guifg=#bbbbbb
hi CursorLine guibg=#ccffff
hi CursorColumn guibg=#f0fefe
hi NonText term=bold cterm=none ctermfg=gray gui=none guifg=#666666 guibg=#f0f0f0

hi Folded term=reverse cterm=none ctermfg=blue ctermbg=gray gui=none guifg=#0099cc guibg=#f0f0f0
hi FoldColumn term=reverse cterm=none ctermbg=black ctermfg=cyan gui=none guibg=#222222 guifg=#cccccc

hi ColorColumn term=reverse cterm=none ctermbg=lightgray gui=none guibg=#ffffe0

" Menu
hi clear Directory
hi Directory term=bold cterm=bold ctermfg=blue gui=bold guifg=#000000

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

" Quickfix
hi QuickFixLine term=reverse cterm=none ctermfg=black ctermbg=lightcyan gui=none guibg=#99ffff guifg=#000000
hi clear qfLineNr
hi clear qfError
hi qfLineNr term=none cterm=none ctermfg=darkmagenta gui=none guifg=#660066
hi qfError term=bold cterm=bold ctermfg=red gui=bold guifg=#990000

" Git Gutter
let g:gitgutter_override_sign_column_highlight = 0
hi GitGutterAdd term=standout ctermfg=lightgreen ctermbg=black guibg=#222222 guifg=#00cc33
hi GitGutterChange term=standout ctermfg=cyan ctermbg=black guibg=#222222 guifg=#0099ff
hi GitGutterDelete term=standout ctermfg=lightred ctermbg=black guibg=#222222 guifg=#ff3300
hi GitGutterChangeDelete term=standout ctermfg=lightmagenta ctermbg=black guibg=#222222 guifg=#ff0066
hi GitGutterChangeDeleteInvisible ctermfg=black ctermbg=black guibg=#222222 guifg=#000000
hi GitGutterChangeInvisible ctermfg=black ctermbg=black guibg=#222222 guifg=#000000
hi GitGutterDeleteInvisible ctermfg=black ctermbg=black guibg=#222222 guifg=#000000
hi GitGutterAddInvisible ctermfg=black ctermbg=black guibg=#222222 guifg=#000000

hi ALEWarningSign term=standout cterm=bold ctermfg=yellow ctermbg=black gui=bold guibg=#222222 guifg=#ffcc00
hi ALEErrorSign term=standout cterm=bold ctermfg=lightred ctermbg=black gui=bold guibg=#222222 guifg=#ff0033

hi link CocWarningSign ALEWarningSign
hi link CocErrorSign ALEErrorSign
hi link CocInfoSign GitGutterAdd
hi link CocInfoSign GitGutterChange

hi CocFloating term=standout cterm=none ctermfg=white ctermbg=blue gui=none guibg=#ddddff
hi CocErrorFloat term=standout cterm=none ctermfg=white ctermbg=red gui=none guifg=#ffffff guibg=#cc0000
hi CocWarningFloat term=standout cterm=none ctermfg=white ctermbg=darkyellow gui=none guifg=#ffffff guibg=#cc6600
hi CocInfoFloat term=standout cterm=none ctermfg=white ctermbg=green gui=none guifg=#ffffff guibg=#00aa99
hi CocHintFloat term=standout cterm=none ctermfg=white ctermbg=green gui=none guifg=#ffffff guibg=#339999
hi link CocErrorHighlight SpellBad
hi link CocWarningHighlight SpellCap
hi link CocInfoHighlight SpellLocal
hi link CocHintHighlight SpellRare
hi link CocHighlightText CursorLine

hi link SyntasticErrorSign ALEErrorSign
hi link SyntasticWarningSign ALEWarningSign
hi SyntasticStyleErrorSign term=standout ctermfg=darkyellow ctermbg=black guibg=#222222 guifg=#cccc00
hi SyntasticStyleWarningSign term=standout ctermfg=darkmagenta ctermbg=black guibg=#222222 guifg=#996633

if &background == "dark"
    hi Normal term=none cterm=none gui=none guifg=#aaaaaa guibg=#080811
    hi NormalNC term=none cterm=none gui=none guifg=#999999
    hi Terminal term=none cterm=none gui=none guifg=#aaaaaa guibg=#080811

    hi LineNr term=reverse cterm=none ctermbg=black ctermfg=darkgray gui=none guibg=#222222 guifg=#666666

    hi SpecialKey term=reverse cterm=bold ctermfg=cyan gui=bold guibg=#0066cc guifg=#f0f0ff
    hi WhiteSpace term=standout cterm=none ctermfg=darkblue gui=none guifg=#330066
    hi Conceal term=underline cterm=none ctermfg=darkgray gui=none guifg=#333333

    hi Comment term=underline cterm=none ctermfg=darkgray gui=none guifg=#666666
    hi SpecialComment term=underline cterm=none ctermfg=darkcyan gui=none guifg=#666699

    hi Constant term=none cterm=none ctermfg=lightblue gui=none guifg=#00aadd
    hi Boolean term=none cterm=none ctermfg=lightblue gui=none guifg=#00aadd
    hi Number term=none cterm=none ctermfg=lightblue gui=none guifg=#00bbdd
    hi Float term=none cterm=none ctermfg=lightblue gui=none guifg=#00bbdd
    hi Character term=none cterm=none ctermfg=lightblue gui=none guifg=#00bbff
    hi String term=none cterm=none ctermfg=magenta gui=none guifg=#cc99cc

    hi Identifier term=none cterm=none ctermfg=cyan gui=none guifg=#33aacc
    hi Function term=none cterm=none gui=none guifg=#ccccff

    hi Statement term=none cterm=bold gui=bold guifg=#ccccff
    hi Label term=bold cterm=bold ctermfg=lightblue gui=bold guifg=#33cc99
    hi Operator term=none cterm=none gui=none guifg=#ffffff
    hi Keyword term=bold cterm=bold gui=bold guifg=#f0f0ff

    hi PreProc term=none cterm=bold ctermfg=green gui=bold guifg=#00aa33
    hi Include term=none cterm=bold ctermfg=lightgreen gui=none guifg=#00ff66
    hi Macro term=none cterm=bold ctermfg=lightgreen gui=none guifg=#00ff66

    hi Structure term=none cterm=bold gui=bold guifg=#ffffff
    hi StorageClass term=none cterm=bold gui=bold guifg=#ffffff
    hi Typedef term=none cterm=bold gui=bold guifg=#5dd8ff
    hi Type term=none cterm=bold gui=bold guifg=#99ccff

    hi Special term=bold cterm=none ctermfg=cyan gui=none guifg=#99bbff

    hi IncSearch term=reverse cterm=reverse,underline gui=reverse guifg=#cc6600 guibg=#ffffff
    hi Search term=reverse cterm=reverse gui=none guibg=#333366

    hi Visual term=reverse cterm=reverse gui=none guibg=#003399
    hi MatchParen term=reverse ctermbg=cyan guibg=#333399

    hi StatusLine term=bold,reverse cterm=reverse gui=reverse guifg=#0066cc guibg=#ffffff
    hi StatusLineNC term=bold,reverse cterm=reverse gui=reverse guifg=#336699 guibg=#aaaaaf

    hi WarningMsg term=standout cterm=bold ctermfg=yellow gui=bold guifg=#ff9900

    hi CursorLine guibg=#333333
    hi CursorColumn guibg=#030303
    hi NonText term=bold cterm=none ctermfg=darkgray gui=none guifg=#666666 guibg=#222222

    hi Folded term=reverse cterm=none ctermfg=yellow ctermbg=darkblue gui=none guifg=#ff9966 guibg=#222222

    hi Todo term=standout cterm=none ctermfg=white ctermbg=darkgreen gui=none guifg=#ccffcc guibg=#009966

    hi DiffAdd term=bold ctermfg=white ctermbg=darkmagenta guibg=#660066
    hi DiffDelete term=reverse ctermfg=darkred ctermbg=darkblue guibg=#000066 guifg=#660000
    hi DiffChange term=bold ctermfg=lightgray ctermbg=darkblue guibg=#222222
    hi DiffText term=reverse ctermfg=lightcyan ctermbg=darkblue gui=none guibg=#444444

    hi Directory term=bold cterm=bold ctermfg=white gui=bold guifg=#ffffff
    hi ColorColumn term=reverse cterm=none ctermbg=darkblue gui=none guibg=#080808

    hi TabLine term=reverse cterm=none ctermfg=gray ctermbg=darkblue gui=none guibg=#222222 guifg=#999999
    hi TabLineSel term=bold,reverse cterm=underline,bold ctermfg=white ctermbg=blue gui=underline guibg=#bbbbbb guifg=#330000

    hi PMenu term=reverse cterm=none ctermfg=gray ctermbg=darkblue gui=none guibg=#000099 guifg=#cccccc
    hi PMenuSel term=bold cterm=bold ctermfg=black ctermbg=gray gui=bold guifg=#000066 guibg=#cccccc
    hi PMenuSBar term=reverse cterm=none ctermfg=gray ctermbg=darkblue gui=none guibg=#000099 guifg=#00cccc
    hi PMenuThumb term=reverse,bold cterm=none ctermfg=gray ctermbg=darkred gui=none guibg=#660000 guifg=#ff6600

    hi qfLineNr term=none cterm=none ctermfg=lightmagenta gui=none guifg=#cc00cc
    hi qfError term=bold cterm=bold ctermfg=lightred gui=bold guifg=#cc0000

    let g:terminal_color_0 = '#000000'
    let g:terminal_color_1 = '#cc0000'
    let g:terminal_color_2 = '#009900'
    let g:terminal_color_3 = '#cc6600'
    let g:terminal_color_4 = '#0033cc'
    let g:terminal_color_5 = '#aa00aa'
    let g:terminal_color_6 = '#6699cc'
    let g:terminal_color_7 = '#bbbbbb'
    let g:terminal_color_8 = '#333333'
    let g:terminal_color_9 = '#ff6633'
    let g:terminal_color_10 = '#00cc33'
    let g:terminal_color_11 = '#ff9900'
    let g:terminal_color_12 = '#0099ff'
    let g:terminal_color_13 = '#cc33ff'
    let g:terminal_color_14 = '#00ccff'
    let g:terminal_color_15 = '#ffffff'

    function! g:BuffetSetCustomColors()
        hi! BuffetCurrentBuffer term=bold,reverse cterm=bold ctermfg=white ctermbg=blue gui=underline guibg=#bbbbbb guifg=#333366
        hi! BuffetBuffer term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#222222 guifg=#999999
        hi! BuffetActiveBuffer term=reverse cterm=none ctermfg=cyan ctermbg=blue gui=none guibg=#222222 guifg=#99bbcc
        hi! BuffetTrunc term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#222222 guifg=#666666
        hi! BuffetTab term=reverse cterm=none ctermfg=red ctermbg=blue gui=none guibg=#222222 guifg=#666666
        hi! BuffetModCurrentBuffer term=bold,reverse cterm=bold ctermfg=white ctermbg=blue gui=underline guibg=#bbbbbb guifg=#222233
        hi! BuffetModBuffer term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#222222 guifg=#aa9999
        hi! BuffetModActiveBuffer term=reverse cterm=none ctermfg=lightblue ctermbg=blue gui=none guibg=#222222 guifg=#cc99cc
    endfunction

    if !empty($TMUX) || !empty($TERM_PROGRAM)
        hi SpellBad guibg=#000000
        hi SpellCap gui=none guibg=#000000
        hi SpellRare gui=none
        hi SpellLocal gui=none
    endif

    hi CocFloating term=standout cterm=none ctermfg=white ctermbg=blue gui=none guibg=#001144

    " Only set the fg white if we are very sure that the bg is dark:
    " a false positive means important text will be potentially invisible,
    " but a false negative is often no big deal since the bold attribute makes
    " the default text white on many terminals anyway.
    if !empty($BACKGROUND) || !empty($TERMFGBG)
        hi Statement ctermfg=white
        hi Operator ctermfg=white
        hi Keyword ctermfg=white
        hi Type ctermfg=white
    else
        hi Operator cterm=bold
    endif
else " Light background
    " Terminal
    let g:terminal_color_0 = '#000000'
    let g:terminal_color_1 = '#990000'
    let g:terminal_color_2 = '#006600'
    let g:terminal_color_3 = '#cc6600'
    let g:terminal_color_4 = '#000099'
    let g:terminal_color_5 = '#660066'
    let g:terminal_color_6 = '#6699cc'
    let g:terminal_color_7 = '#bbbbbb'
    let g:terminal_color_8 = '#333333'
    let g:terminal_color_9 = '#993300'
    let g:terminal_color_10 = '#009900'
    let g:terminal_color_11 = '#ff9900'
    let g:terminal_color_12 = '#0066cc'
    let g:terminal_color_13 = '#9966cc'
    let g:terminal_color_14 = '#0099ff'
    let g:terminal_color_15 = '#ffffff'

    " vim-buffet
    function! g:BuffetSetCustomColors()
        hi! BuffetCurrentBuffer term=bold,reverse cterm=bold ctermfg=white ctermbg=blue  gui=underline guibg=#fafafa guifg=#000000
        hi! BuffetBuffer term=reverse cterm=none ctermfg=gray ctermbg=blue gui=none guibg=#cccccc guifg=#403f53
        hi! BuffetActiveBuffer term=reverse cterm=none ctermfg=cyan ctermbg=blue gui=none guibg=#cccccc guifg=#403f53
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
endif

hi clear SignColumn
hi link SignColumn LineNr

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

" A color scheme for Vim by Kimmo Kulovesi <http://arkku.com/>.
"
" Set 'background' to 'light' or 'dark' according to your
" terminal's background color. The background color should be
" either white (for 'light') or black (for 'dark').

hi clear Normal
"set background&
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name = "arkku"

if &background == "light"
    hi Normal guifg=black guibg=white
    hi DiffText term=reverse cterm=none ctermbg=lightgray gui=none guibg=lightgray
    hi Directory term=bold cterm=none ctermfg=lightblue gui=none guifg=#003399
    hi WarningMsg term=standout cterm=bold ctermfg=darkred gui=bold guifg=darkred
    hi LineNr term=reverse cterm=reverse ctermfg=black ctermbg=gray gui=reverse guifg=black guibg=gray
else
    hi Directory term=bold cterm=none ctermfg=lightblue gui=none guifg=#0099FF
    hi Normal guifg=gray90 guibg=black
    hi DiffText term=reverse cterm=none ctermbg=darkblue gui=none guibg=darkblue
    hi WarningMsg term=standout cterm=bold ctermfg=lightred gui=bold guifg=#FF3300
    hi LineNr term=reverse cterm=reverse ctermfg=black ctermbg=gray gui=none guifg=#666699 guibg=black
endif

hi Title term=bold cterm=bold ctermfg=yellow gui=bold guifg=#FF9900
hi Underlined term=underline cterm=underline ctermfg=none gui=underline guifg=fg
hi ScrollBar guifg=darkcyan guibg=cyan
hi Menu guifg=white guibg=blue
hi WildMenu term=standout cterm=bold gui=bold
hi SpecialKey term=bold cterm=bold gui=bold
hi cIf0 ctermfg=darkgray guifg=darkgray

hi NonText term=bold cterm=none ctermfg=gray gui=reverse guifg=black guibg=gray

hi Search term=underline cterm=underline ctermfg=none ctermbg=none gui=underline guifg=fg guibg=bg
hi IncSearch term=reverse cterm=bold ctermfg=black ctermbg=yellow gui=bold guifg=black guibg=#FF9900
hi clear Visual
hi Visual term=reverse cterm=reverse gui=reverse
hi VisualNOS term=reverse cterm=reverse gui=reverse

hi MoreMsg term=bold cterm=bold ctermfg=lightblue gui=bold guifg=#0099FF
hi ModeMsg term=bold cterm=bold ctermfg=lightblue gui=bold guifg=#0099FF
hi ErrorMsg term=standout cterm=none ctermfg=white ctermbg=darkred gui=none guifg=white guibg=darkred
hi Question term=standout cterm=none ctermfg=black ctermbg=yellow gui=none guifg=black guibg=#FF9900
hi StatusLine term=bold,reverse cterm=reverse gui=reverse
hi StatusLineNC term=reverse cterm=reverse gui=reverse
hi VertSplit term=reverse cterm=none ctermfg=white ctermbg=darkgray gui=none guifg=white guibg=darkgray
hi Tooltip term=reverse cterm=none ctermfg=black ctermbg=yellow gui=none guifg=black guibg=#FF9900

hi Folded term=standout cterm=none ctermfg=darkblue ctermbg=lightgray gui=none guifg=darkblue guibg=lightgray
hi FoldedColumn term=standout cterm=none ctermfg=darkblue ctermbg=lightgray gui=none guifg=darkblue guibg=lightgray

hi DiffAdd term=bold cterm=none ctermfg=darkgreen ctermbg=lightgray gui=none guifg=darkgreen guibg=lightgray
hi DiffChange term=bold cterm=none ctermfg=brown ctermbg=lightgray gui=none guifg=brown guibg=lightgray
hi DiffDelete term=bold cterm=none ctermfg=darkred ctermbg=lightgray gui=none guifg=darkred guibg=lightgray

" Syntax hilight:
if &background == "light"
    hi Ignore term=none cterm=none ctermfg=white gui=none guifg=white
    hi Comment term=underline cterm=none ctermfg=gray gui=none guifg=#CCCCCC
    hi SpecialComment term=none cterm=none ctermfg=darkgray gui=none guifg=#663300
    hi Identifier term=none cterm=none ctermfg=darkred gui=none guifg=darkred
    hi Statement term=bold cterm=none ctermfg=darkblue gui=none guifg=darkblue
    hi PreProc term=none cterm=bold ctermfg=darkgray gui=bold guifg=#333333
    hi String term=none cterm=none ctermfg=brown gui=none guifg=#CC6600
    hi Constant term=none cterm=none ctermfg=darkgreen gui=none guifg=darkgreen
    hi Special term=bold cterm=none ctermfg=darkcyan gui=none guifg=darkcyan
else
    hi Ignore term=none cterm=none ctermfg=black gui=none guifg=black
    hi Comment term=none cterm=none ctermfg=darkgray gui=none guifg=#666666
    hi SpecialComment term=none cterm=none ctermfg=cyan gui=none guifg=#669999
    hi Identifier term=underline cterm=none ctermfg=magenta gui=none guifg=#FF9900
    hi Statement term=bold cterm=none ctermfg=lightblue gui=none guifg=#0099FF
    hi PreProc term=none cterm=none ctermfg=brown gui=none guifg=#FF6600
    hi String term=none cterm=none ctermfg=darkgreen gui=none guifg=#009900
    hi Constant term=none cterm=none ctermfg=darkgreen gui=none guifg=#009900
    hi Special term=bold cterm=none ctermfg=darkcyan gui=none guifg=#0099FF
endif

hi link Label Statement
hi link Operator Statement
hi link Function Statement

hi link Include Preproc
hi link Define Preproc
hi link Macro Preproc
hi link PreCondit Preproc

hi link Character Constant
hi link Boolean Constant
hi link Number Constant
hi link Float Constant

hi link SpecialChar Special
hi link Delimiter Special
hi link Tag Special

hi Keyword term=none cterm=bold ctermfg=none gui=bold guifg=fg
hi link Type Keyword
hi link StorageClass Keyword
hi link Structure Keyword
hi link Typedef Keyword

hi link Conditional Keyword
hi link Repeat Keyword
hi link Exception Keyword
hi link Keyword Keyword

hi Error term=reverse cterm=none ctermfg=white ctermbg=darkred gui=none guifg=white guibg=darkred
hi Todo term=standout cterm=none ctermfg=white ctermbg=darkgreen gui=none guifg=white guibg=darkgreen

if exists('g:loaded_arkku_local_settings')
    finish
else
    let g:loaded_arkku_local_settings=1
endif

if !has('nvim')
    " Silence complaint
    let g:yoinkInitialized = 1
endif

"let g:syntastic_swift_checkers = [ 'swiftpm', 'swiftlint' ]
let g:syntastic_swift_checkers = [ 'swiftlint' ]
"let g:syntastic_c_checkers = [ 'make' ]
"let g:syntastic_cpp_checkers = [ 'make' ]
let g:syntastic_c_checkers = []
let g:syntastic_cpp_checkers = []
let g:syntastic_objc_checkers = []
let g:syntastic_objcpp_checkers = []

au CursorHold * silent! call CocActionAsync('highlight')

" \d to jump to definition of thing under cursor
noremap <Leader>d :call CocAction('jumpDefinition')<CR>

" \r to show all references of thing under cursor
nmap <Leader>r <Plug>(coc-references)

" Create mappings for function text object
xmap <silent> if <Plug>(coc-funcobj-i)
xmap <silent> af <Plug>(coc-funcobj-a)
omap <silent> if <Plug>(coc-funcobj-i)
omap <silent> af <Plug>(coc-funcobj-a)

" Tab in visual mode for coc range select
xmap <silent> <Tab> <Plug>(coc-range-select)

" \cc for coc code action
nmap <Leader>c <Plug>(coc-codeaction)
xmap <Leader>c <Plug>(coc-codeaction-selected)

" \cf for coc fix
nmap <Leader>cf <Plug>(coc-fix-current)

" \cr to rename thing under cursor
nmap <Leader>cr <Plug>(coc-rename)
nmap <Leader>R <Plug>(coc-rename)

nnoremap <silent> <LocalLeader>r :<C-u>CocListResume<CR>
nnoremap <silent> <LocalLeader>s :<C-u>CocList -I symbols<CR>
nnoremap <silent> <LocalLeader>o :<C-u>CocList outline<CR>
nnoremap <silent> <LocalLeader>k :<C-u>CocNext<CR>
nnoremap <silent> <LocalLeader>j :<C-u>CocPrev<CR>

augroup localcocsettings
    autocmd!
    " Setup formatexpr specified filetypes
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end


let g:ale_c_clang_options = '--std=c11 -Wall -Wextra'
let g:ale_cpp_clang_options = '--std=c++17 -Wall -Wextra'
let g:ale_objc_clang_options = '-Wall -Wextra'

let g:ale_linters = {'c': ['clang'], 'cpp': ['clang']}

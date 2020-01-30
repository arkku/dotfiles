if exists('g:loaded_arkku_local_settings')
    finish
else
    let g:loaded_arkku_local_settings=1
endif

"let g:syntastic_swift_checkers = [ 'swiftpm', 'swiftlint' ]
let g:syntastic_swift_checkers = [ 'swiftlint' ]
"let g:syntastic_c_checkers = [ 'make' ]
"let g:syntastic_cpp_checkers = [ 'make' ]
let g:syntastic_c_checkers = []
let g:syntastic_cpp_checkers = []
let g:syntastic_objc_checkers = []
let g:syntastic_objcpp_checkers = []

" Create mappings for function text object
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

xmap <silent> <Tab> <Plug>(coc-range-select)

nnoremap <silent> <LocalLeader>r :<C-u>CocListResume<CR>
nnoremap <silent> <LocalLeader>s :<C-u>CocList -I symbols<CR>
nnoremap <silent> <LocalLeader>o :<C-u>CocList outline<CR>
nnoremap <silent> <LocalLeader>k :<C-u>CocNext<CR>
nnoremap <silent> <LocalLeader>j :<C-u>CocPrev<CR>

let g:ale_c_clang_options = '--std=c11 -Wall -Wextra'
let g:ale_cpp_clang_options = '--std=c++17 -Wall -Wextra'
let g:ale_objc_clang_options = '-Wall -Wextra'

let g:ale_linters = {'c': ['clang'], 'cpp': ['clang']}
